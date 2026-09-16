#!/usr/bin/env bash
# setup-memory.sh
# Copies work memory files from this repo into the local Claude Code memory path.
# Run once on a new machine after cloning claude-commands.
#
# Usage:
#   ./setup-memory.sh                          # uses ~/github as the working dir
#   ./setup-memory.sh /path/to/working/dir    # custom working dir

set -euo pipefail

WORK_DIR="${1:-$HOME/github}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MEMORY_SRC="$SCRIPT_DIR/memory"

# Claude Code encodes the working dir path as: strip leading slash, replace / with -
ENCODED=$(echo "$WORK_DIR" | sed 's|^/||; s|/|-|g')
MEMORY_DEST="$HOME/.claude/projects/-${ENCODED}/memory"

echo "Working dir:  $WORK_DIR"
echo "Encoded path: -${ENCODED}"
echo "Destination:  $MEMORY_DEST"
echo ""

if [ ! -d "$MEMORY_SRC" ]; then
  echo "ERROR: memory/ directory not found in $SCRIPT_DIR"
  exit 1
fi

mkdir -p "$MEMORY_DEST"

# Copy all memory files, skipping project-specific ones that shouldn't travel
SKIPPED=()
COPIED=()

for file in "$MEMORY_SRC"/*.md; do
  fname="$(basename "$file")"

  # Project memories contain machine-specific paths or sprint data — skip them
  if [[ "$fname" == project_sprint* ]]; then
    SKIPPED+=("$fname (sprint data — stale on new machine)")
    continue
  fi

  cp "$file" "$MEMORY_DEST/$fname"
  COPIED+=("$fname")
done

echo "Copied ${#COPIED[@]} memory files to $MEMORY_DEST"
echo ""

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "Skipped (stale on new machine):"
  for f in "${SKIPPED[@]}"; do
    echo "  - $f"
  done
  echo ""
fi

echo "Done. Open Claude Code from $WORK_DIR and memory will be active."
