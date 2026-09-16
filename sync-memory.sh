#!/usr/bin/env bash
# sync-memory.sh
# Copies local Claude Code memory files back into this repo and pushes.
# Run any time you want to save new or updated memories to the remote.
#
# Usage:
#   ./sync-memory.sh                          # uses ~/github as the working dir
#   ./sync-memory.sh /path/to/working/dir    # custom working dir

set -euo pipefail

WORK_DIR="${1:-$HOME/github}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MEMORY_DEST="$SCRIPT_DIR/memory"

ENCODED=$(echo "$WORK_DIR" | sed 's|^/||; s|/|-|g')
MEMORY_SRC="$HOME/.claude/projects/-${ENCODED}/memory"

echo "Source:      $MEMORY_SRC"
echo "Destination: $MEMORY_DEST"
echo ""

if [ ! -d "$MEMORY_SRC" ]; then
  echo "ERROR: local memory directory not found at $MEMORY_SRC"
  exit 1
fi

mkdir -p "$MEMORY_DEST"
cp "$MEMORY_SRC"/*.md "$MEMORY_DEST/"

# Check if anything actually changed
cd "$SCRIPT_DIR"
if git diff --quiet memory/ && git ls-files --others --exclude-standard memory/ | grep -q ''; then
  # New untracked files exist
  :
elif git diff --quiet memory/; then
  echo "Nothing changed — memory is already up to date."
  exit 0
fi

CHANGED=$(git diff --name-only memory/ && git ls-files --others --exclude-standard memory/)
echo "Changes detected:"
echo "$CHANGED" | sed 's/^/  /'
echo ""

git add memory/
git commit -m "sync memory: $(date '+%Y-%m-%d')"
git push

echo ""
echo "Memory synced and pushed."
