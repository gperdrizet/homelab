#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  rsync_selected_from_arkk.sh -f TARGETS_FILE -d DEST_ROOT [options]

Required:
  -f TARGETS_FILE   Text file of paths to copy (one per line, relative to source root)
  -d DEST_ROOT      Local destination root on backup machine

Optional:
  -s SOURCE         Remote source root (default: siderealyear@arkk:/mnt/arkk)
  -x EXCLUDES_FILE  rsync exclude patterns file (applied to every target)
  -n                Dry run
  -z                Enable rsync compression
  -e SSH_CMD        SSH command for rsync (example: ssh -p 44441)
  -h                Show help

Targets file format:
  - One path per line
  - Blank lines ignored
  - Lines beginning with # are ignored
  - Paths are interpreted relative to source root

Example:
  ./rsync_selected_from_arkk.sh \
    -f ./targets.txt \
    -x ./excludes.txt \
    -d /srv/backups/arkk \
    -s siderealyear@arkk:/mnt/arkk \
    -e "ssh -p 22"
EOF
}

SOURCE="siderealyear@arkk:/mnt/arkk"
TARGETS_FILE=""
DEST_ROOT=""
DRY_RUN=0
USE_COMPRESSION=0
SSH_CMD=""
EXCLUDES_FILE=""

while getopts ":f:d:s:x:e:nzh" opt; do
  case "$opt" in
    f) TARGETS_FILE="$OPTARG" ;;
    d) DEST_ROOT="$OPTARG" ;;
    s) SOURCE="$OPTARG" ;;
    x) EXCLUDES_FILE="$OPTARG" ;;
    e) SSH_CMD="$OPTARG" ;;
    n) DRY_RUN=1 ;;
    z) USE_COMPRESSION=1 ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "Missing argument for -$OPTARG" >&2
      usage
      exit 1
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$TARGETS_FILE" || -z "$DEST_ROOT" ]]; then
  echo "Both -f TARGETS_FILE and -d DEST_ROOT are required." >&2
  usage
  exit 1
fi

if [[ ! -f "$TARGETS_FILE" ]]; then
  echo "Targets file not found: $TARGETS_FILE" >&2
  exit 1
fi

if [[ -n "$EXCLUDES_FILE" && ! -f "$EXCLUDES_FILE" ]]; then
  echo "Excludes file not found: $EXCLUDES_FILE" >&2
  exit 1
fi

mkdir -p "$DEST_ROOT"

RSYNC_OPTS=(
  -aHAX
  --numeric-ids
  --partial
  --append-verify
  --info=progress2
)

if [[ $DRY_RUN -eq 1 ]]; then
  RSYNC_OPTS+=(--dry-run)
fi

if [[ $USE_COMPRESSION -eq 1 ]]; then
  RSYNC_OPTS+=(-z)
fi

if [[ -n "$SSH_CMD" ]]; then
  RSYNC_OPTS+=(-e "$SSH_CMD")
fi

if [[ -n "$EXCLUDES_FILE" ]]; then
  RSYNC_OPTS+=(--exclude-from="$EXCLUDES_FILE")
fi

echo "Source: $SOURCE"
echo "Destination root: $DEST_ROOT"
echo "Targets file: $TARGETS_FILE"
if [[ -n "$EXCLUDES_FILE" ]]; then
  echo "Excludes file: $EXCLUDES_FILE"
fi
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Mode: DRY RUN"
fi

copy_count=0
skip_count=0

while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  line="${raw_line%$'\r'}"

  # Ignore comments and blank lines.
  if [[ -z "${line//[[:space:]]/}" ]]; then
    continue
  fi
  if [[ "$line" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  rel_path="$line"
  rel_path="${rel_path#./}"
  rel_path="${rel_path#/}"

  if [[ -z "$rel_path" ]]; then
    ((skip_count++))
    continue
  fi

  parent_dir="$(dirname "$rel_path")"
  mkdir -p "$DEST_ROOT/$parent_dir"

  echo
  echo "==> Copying: $rel_path"
  rsync "${RSYNC_OPTS[@]}" "$SOURCE/$rel_path" "$DEST_ROOT/$parent_dir/"
  ((copy_count++))
done < "$TARGETS_FILE"

echo
echo "Completed. Copied targets: $copy_count, skipped entries: $skip_count"
echo "Tip: run the same command a second time to catch retries/partials."
