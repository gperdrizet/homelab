#!/usr/bin/env bash
set -euo pipefail

# Thin GAN training checkpoints from arkk into the rescue backup.
#
# For each training_checkpoints directory listed in the dirs file, keep a sparse,
# evenly-spaced ladder of ~KEEP checkpoints (by frame number) PLUS the final one,
# and drop the rest. Both generator_model_f* and discriminator_model_f* at each
# kept frame are copied when present. Handles both flat .h5 checkpoint files and
# TensorFlow SavedModel checkpoint directories.
#
# Default transport is a LOCAL source path (e.g. arkk NFS-mounted on this host
# over the bonded GbE link). Pass -H to use ssh/rsync-over-ssh instead.
#
# The bulk backup (rsync_selected_from_arkk.sh) excludes training_checkpoints/
# entirely; this script copies back only the thinned ladder.

usage() {
  cat <<'EOF'
Usage:
  thin_checkpoints_from_arkk.sh -l DIRS_FILE -d DEST_ROOT [options]

Required:
  -l DIRS_FILE   File of training_checkpoints paths (relative to source root),
                 one per line. Inline "# ..." comments are stripped.
  -d DEST_ROOT   Local destination root on the backup machine.

Optional:
  -H SOURCE_HOST  ssh host for remote mode (default: empty = local mount mode)
  -r SOURCE_ROOT  Source root (default: /mnt/arkk; local NFS mount or remote path)
  -k KEEP         Approx. checkpoints to keep per run (default: 35)
  -e SSH_CMD      SSH command, used only with -H (default: ssh)
  -n              Dry run (plan only; no files copied)
  -h              Show help

Example (local NFS mount over bonded GbE):
  ./thin_checkpoints_from_arkk.sh \
    -l ./checkpoint_dirs.txt \
    -d /mnt/glass/arkk \
    -r /mnt/arkk \
    -k 35 -n
EOF
}

SOURCE_HOST=""
SOURCE_ROOT="/mnt/arkk"
DEST_ROOT=""
DIRS_FILE=""
KEEP=35
SSH_CMD="ssh"
DRY_RUN=0

while getopts ":l:d:H:r:k:e:nh" opt; do
  case "$opt" in
    l) DIRS_FILE="$OPTARG" ;;
    d) DEST_ROOT="$OPTARG" ;;
    H) SOURCE_HOST="$OPTARG" ;;
    r) SOURCE_ROOT="$OPTARG" ;;
    k) KEEP="$OPTARG" ;;
    e) SSH_CMD="$OPTARG" ;;
    n) DRY_RUN=1 ;;
    h) usage; exit 0 ;;
    :) echo "Missing argument for -$OPTARG" >&2; usage; exit 1 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$DIRS_FILE" || -z "$DEST_ROOT" ]]; then
  echo "Both -l DIRS_FILE and -d DEST_ROOT are required." >&2
  usage
  exit 1
fi
if [[ ! -f "$DIRS_FILE" ]]; then
  echo "Dirs file not found: $DIRS_FILE" >&2
  exit 1
fi
if ! [[ "$KEEP" =~ ^[0-9]+$ ]] || (( KEEP < 1 )); then
  echo "KEEP must be a positive integer (got: $KEEP)" >&2
  exit 1
fi

mkdir -p "$DEST_ROOT"

FILES_FROM="$(mktemp)"
trap 'rm -f "$FILES_FROM"' EXIT

total_dirs=0
total_kept=0

echo "Destination root: $DEST_ROOT"
echo "Keep per run: ~$KEEP + final"
if [[ -n "$SOURCE_HOST" ]]; then
  echo "Source: $SOURCE_HOST:$SOURCE_ROOT (ssh)"
else
  echo "Source: $SOURCE_ROOT (local mount)"
fi
[[ $DRY_RUN -eq 1 ]] && echo "Mode: DRY RUN (plan only)"
echo

while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  line="${raw_line%$'\r'}"
  line="${line%%#*}"                       # strip inline comments
  line="${line#"${line%%[![:space:]]*}"}"  # ltrim
  line="${line%"${line##*[![:space:]]}"}"  # rtrim
  [[ -z "$line" ]] && continue

  ckpt_dir="${line#./}"
  ckpt_dir="${ckpt_dir#/}"

  # List the checkpoint directory contents from the source.
  if [[ -n "$SOURCE_HOST" ]]; then
    # Remote (ssh) mode. stdin from /dev/null so ssh does not consume the
    # while-read loop's stdin (DIRS_FILE) and truncate the iteration.
    mapfile -t entries < <("$SSH_CMD" "$SOURCE_HOST" "ls -1 -- '$SOURCE_ROOT/$ckpt_dir' 2>/dev/null" < /dev/null || true)
  else
    # Local mode (e.g. NFS mount) — list directly.
    mapfile -t entries < <(ls -1 -- "$SOURCE_ROOT/$ckpt_dir" 2>/dev/null || true)
  fi
  if [[ ${#entries[@]} -eq 0 ]]; then
    echo "==> $ckpt_dir: empty or unreadable, skipping"
    continue
  fi

  # Collect sorted, unique generator frame ids. Frames are usually 7-digit zero
  # padded (e.g. generator_model_f0024147) but some legacy runs omit the "f" and
  # use short epoch numbers (e.g. generator_model_002.h5). Zero-padded ids sort
  # lexically == numerically.
  mapfile -t frames < <(
    printf '%s\n' "${entries[@]}" \
      | sed -n 's/^generator_model_f\{0,1\}\([0-9]\{1,\}\)\(\.h5\)\{0,1\}$/\1/p' \
      | sort -u
  )
  n=${#frames[@]}
  if (( n == 0 )); then
    # No recognizable generator_model_* checkpoints (e.g. TF-native ckpt-N
    # format). These are the small legacy dirs; copy the whole directory.
    echo "==> $ckpt_dir: no generator_model_* frames (${#entries[@]} entries); copying whole (small legacy dir)"
    printf '%s\n' "$ckpt_dir" >> "$FILES_FROM"
    total_dirs=$((total_dirs + 1))
    total_kept=$((total_kept + 1))
    continue
  fi

  # Choose an evenly spaced ladder of ~KEEP frames, always including the last.
  declare -A keep_frame=()
  if (( n <= KEEP )); then
    for f in "${frames[@]}"; do keep_frame["$f"]=1; done
  else
    stride=$(( (n + KEEP - 1) / KEEP ))   # ceil(n / KEEP)
    for (( i = 0; i < n; i += stride )); do keep_frame["${frames[i]}"]=1; done
    keep_frame["${frames[n-1]}"]=1        # always keep the final checkpoint
  fi

  # Emit files-from lines for every entry (gen + disc, .h5 or SavedModel dir)
  # whose frame id is in the keep set.
  kept_here=0
  for e in "${entries[@]}"; do
    f=""
    case "$e" in
      generator_model_*|discriminator_model_*)
        f="${e#*_model_}"   # strip up to and including _model_
        f="${f#f}"          # strip optional leading f
        f="${f%.h5}"        # strip optional .h5 suffix
        ;;
      *) continue ;;
    esac
    [[ "$f" =~ ^[0-9]+$ ]] || continue
    [[ -n "${keep_frame[$f]:-}" ]] || continue
    printf '%s/%s\n' "$ckpt_dir" "$e" >> "$FILES_FROM"
    kept_here=$((kept_here + 1))
  done

  unset keep_frame
  total_dirs=$((total_dirs + 1))
  total_kept=$((total_kept + kept_here))
  printf '==> %s: %d checkpoints present -> keeping %d entries\n' "$ckpt_dir" "$n" "$kept_here"
done < "$DIRS_FILE"

echo
echo "Planned: $total_dirs dirs, $total_kept checkpoint entries to copy."

if [[ $total_kept -eq 0 ]]; then
  echo "Nothing to copy."
  exit 0
fi

RSYNC_OPTS=(
  -aHAX
  --numeric-ids
  --partial
  --append-verify
  --info=progress2
  --stats
  --files-from="$FILES_FROM"
)
[[ -n "$SOURCE_HOST" ]] && RSYNC_OPTS+=(-e "$SSH_CMD")
[[ $DRY_RUN -eq 1 ]] && RSYNC_OPTS+=(--dry-run)

echo
echo "Running rsync (files-from ladder)..."
# --files-from paths are relative to SOURCE_ROOT; rsync recreates them under DEST_ROOT.
if [[ -n "$SOURCE_HOST" ]]; then
  rsync "${RSYNC_OPTS[@]}" "$SOURCE_HOST:$SOURCE_ROOT/" "$DEST_ROOT/"
else
  rsync "${RSYNC_OPTS[@]}" "$SOURCE_ROOT/" "$DEST_ROOT/"
fi

echo
echo "Done. Re-run to catch partials (rsync will skip already-complete files)."
