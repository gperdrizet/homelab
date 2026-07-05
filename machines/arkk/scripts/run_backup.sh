#!/usr/bin/env bash
set -uo pipefail

# Orchestrate the arkk rescue backup in two passes, with logging:
#   Pass 1: bulk selective copy   (rsync_selected_from_arkk.sh + targets/excludes)
#   Pass 2: thinned checkpoints   (thin_checkpoints_from_arkk.sh + checkpoint_dirs)
#
# Default transport is a LOCAL source mount (arkk NFS-mounted on this host over
# the bonded GbE link). Run this inside tmux/screen — the transfer takes hours.
#
# rsync exit codes 0 and 24 (source files vanished during transfer) are treated
# as success; anything else is reported.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_ROOT="/mnt/arkk"        # local NFS mountpoint of arkk on this host
DEST_ROOT="/mnt/glass/arkk"    # rescue target (2.7T RAID0)
KEEP=35
JOBS=4
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage:
  run_backup.sh [-s SOURCE_ROOT] [-d DEST_ROOT] [-k KEEP] [-n]

Options:
  -s SOURCE_ROOT  Local source mount of arkk (default: /mnt/arkk)
  -d DEST_ROOT    Rescue destination root    (default: /mnt/glass/arkk)
  -k KEEP         Checkpoints kept per run    (default: 35)
  -j JOBS         Parallel rsync streams for the bulk pass (default: 4)
  -n              Dry run (plan only; passes both -n through)
  -h              Show help

Run inside tmux:
  tmux new -s backup
  ./run_backup.sh -n        # review the plan/size first
  ./run_backup.sh           # real run
EOF
}

while getopts ":s:d:k:j:nh" opt; do
  case "$opt" in
    s) SOURCE_ROOT="$OPTARG" ;;
    d) DEST_ROOT="$OPTARG" ;;
    k) KEEP="$OPTARG" ;;
    j) JOBS="$OPTARG" ;;
    n) DRY_RUN=1 ;;
    h) usage; exit 0 ;;
    :) echo "Missing argument for -$OPTARG" >&2; usage; exit 1 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

TARGETS_FILE="$SCRIPT_DIR/targets.txt"
EXCLUDES_FILE="$SCRIPT_DIR/excludes.txt"
CKPT_DIRS_FILE="$SCRIPT_DIR/checkpoint_dirs.txt"

for f in "$TARGETS_FILE" "$EXCLUDES_FILE" "$CKPT_DIRS_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing required file: $f" >&2
    exit 1
  fi
done

if ! [[ "$JOBS" =~ ^[0-9]+$ ]] || (( JOBS < 1 )); then
  echo "JOBS (-j) must be a positive integer (got: $JOBS)" >&2
  exit 1
fi

# --- Preflight ---
echo "== Preflight =="
echo "Source root: $SOURCE_ROOT"
echo "Destination: $DEST_ROOT"
echo "Keep per run: ~$KEEP + final"
echo "Parallel streams (bulk): $JOBS"
[[ $DRY_RUN -eq 1 ]] && echo "Mode: DRY RUN"

if [[ ! -d "$SOURCE_ROOT" ]]; then
  echo "ERROR: source root $SOURCE_ROOT does not exist. Mount arkk first." >&2
  exit 1
fi
if ! mountpoint -q "$SOURCE_ROOT"; then
  echo "WARNING: $SOURCE_ROOT is not a mountpoint. Continuing, but confirm the" >&2
  echo "         arkk NFS export is actually mounted here." >&2
fi
if [[ -z "$(ls -A "$SOURCE_ROOT" 2>/dev/null)" ]]; then
  echo "ERROR: source root $SOURCE_ROOT is empty. Is arkk mounted?" >&2
  exit 1
fi

if [[ $DRY_RUN -eq 0 ]]; then
  if ! mkdir -p "$DEST_ROOT" 2>/dev/null || [[ ! -w "$DEST_ROOT" ]]; then
    echo "ERROR: destination $DEST_ROOT is not writable." >&2
    echo "       Fix with: sudo chown \"\$USER\" \"$(dirname "$DEST_ROOT")\"" >&2
    exit 1
  fi
fi

LOG_DIR="$DEST_ROOT/_backup_logs"
mkdir -p "$LOG_DIR" 2>/dev/null || LOG_DIR="/tmp"
ts="$(date +%Y%m%d-%H%M%S)"

DRY_FLAG=()
[[ $DRY_RUN -eq 1 ]] && DRY_FLAG=(-n)

run_pass() {
  local name="$1"; shift
  local log="$LOG_DIR/${name}-${ts}.log"
  echo
  echo "== Pass: $name =="
  echo "Log: $log"
  "$@" 2>&1 | tee "$log"
  local rc=${PIPESTATUS[0]}
  if [[ "$name" == bulk ]] && { [[ $rc -eq 0 ]] || [[ $rc -eq 24 ]]; }; then
    return 0
  fi
  if [[ $rc -ne 0 ]]; then
    echo "WARNING: pass '$name' exited with code $rc (see log)."
  fi
  return 0
}

# --- Pass 1: bulk selective copy ---
run_pass bulk \
  "$SCRIPT_DIR/rsync_selected_from_arkk.sh" \
    -f "$TARGETS_FILE" \
    -x "$EXCLUDES_FILE" \
    -d "$DEST_ROOT" \
    -s "$SOURCE_ROOT" \
    -j "$JOBS" \
    "${DRY_FLAG[@]}"

# --- Pass 2: thinned checkpoint ladder ---
run_pass checkpoints \
  "$SCRIPT_DIR/thin_checkpoints_from_arkk.sh" \
    -l "$CKPT_DIRS_FILE" \
    -d "$DEST_ROOT" \
    -r "$SOURCE_ROOT" \
    -k "$KEEP" \
    "${DRY_FLAG[@]}"

echo
echo "== Done =="
echo "Logs in: $LOG_DIR"
echo "Re-run this script to catch partials (rsync skips already-complete files)."
[[ $DRY_RUN -eq 1 ]] && echo "This was a DRY RUN — re-run without -n to transfer."
