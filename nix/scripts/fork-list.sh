#!/usr/bin/env bash
# fork-list: Show all pinned fork inputs from flake.lock
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
LOCK_FILE="$REPO_ROOT/flake.lock"

if [ ! -f "$LOCK_FILE" ]; then
  echo "ERROR: flake.lock not found. Run 'nix flake lock' first."
  exit 1
fi

echo "=== Abstract Fork Registry ==="
echo ""
printf "%-28s %-45s %-20s %s\n" "INPUT" "REPO" "BRANCH" "COMMIT (DATE)"
printf "%-28s %-45s %-20s %s\n" "-----" "----" "------" "-------------"

for input in $(jq -r '.nodes | keys[]' "$LOCK_FILE" | grep '^fork-' | sort); do
  owner=$(jq -r ".nodes[\"$input\"].locked.owner // empty" "$LOCK_FILE")
  repo=$(jq -r ".nodes[\"$input\"].locked.repo // empty" "$LOCK_FILE")
  rev=$(jq -r ".nodes[\"$input\"].locked.rev // empty" "$LOCK_FILE")
  ref=$(jq -r ".nodes[\"$input\"].original.ref // \"default\"" "$LOCK_FILE")
  lastModified=$(jq -r ".nodes[\"$input\"].locked.lastModified // empty" "$LOCK_FILE")

  if [ -n "$rev" ]; then
    date_str=""
    if [ -n "$lastModified" ]; then
      # macOS date -r, fallback to GNU date -d
      date_str=" ($(date -r "$lastModified" +%Y-%m-%d 2>/dev/null || date -d "@$lastModified" +%Y-%m-%d 2>/dev/null || echo "?"))"
    fi
    printf "%-28s %-45s %-20s %s%s\n" \
      "$input" "$owner/$repo" "$ref" "${rev:0:12}" "$date_str"
  fi
done

echo ""
echo "To update a fork: fork-update <name>  (e.g. fork-update cw-plus)"
echo "To update all:    fork-update --all"
