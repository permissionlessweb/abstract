#!/usr/bin/env bash
# fork-update: Update one or all fork inputs in flake.lock
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
LOCK_FILE="$REPO_ROOT/flake.lock"

if [ ! -f "$LOCK_FILE" ]; then
  echo "ERROR: flake.lock not found. Run 'nix flake lock' first."
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: fork-update <fork-name> | --all"
  echo ""
  echo "Examples:"
  echo "  fork-update cw-plus        Update the cw-plus fork"
  echo "  fork-update --all          Update all fork inputs"
  echo ""
  echo "Available forks:"
  jq -r '.nodes | keys[]' "$LOCK_FILE" | grep '^fork-' | sed 's/^fork-/  /' | sort
  exit 1
fi

if [ "$1" = "--all" ]; then
  echo "Updating all fork inputs..."
  for input in $(jq -r '.nodes | keys[]' "$LOCK_FILE" | grep '^fork-' | sort); do
    echo "  $input..."
    nix flake update "$input" --flake "$REPO_ROOT"
  done
  echo ""
  echo "Done. Run 'fork-list' to see new commits."
  echo "Run 'cargo update' in each workspace to pick up changes."
else
  input_name="fork-$1"
  if ! jq -e ".nodes[\"$input_name\"]" "$LOCK_FILE" > /dev/null 2>&1; then
    echo "ERROR: No fork input '$input_name' in flake.lock."
    echo "Available:"
    jq -r '.nodes | keys[]' "$LOCK_FILE" | grep '^fork-' | sed 's/^fork-/  /' | sort
    exit 1
  fi

  echo "Updating $input_name..."
  nix flake update "$input_name" --flake "$REPO_ROOT"
  echo ""
  fork-list | grep "$input_name" || true
  echo ""
  echo "Run 'cargo update' in affected workspaces to pick up changes."
fi
