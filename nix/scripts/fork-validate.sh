#!/usr/bin/env bash
# fork-validate: Check Cargo.toml files for fork consistency
#
# Validates that every crate known to come from a fork repo actually
# references the correct git URL, branch, and version in Cargo.toml.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
EXIT_CODE=0
ISSUES=0

echo "=== Fork Consistency Validation ==="
echo ""

# Each line: GIT_URL|BRANCH_OR_EMPTY|CRATE_NAME|EXPECTED_VERSION
FORK_EXPECTATIONS=(
  # cw-minus
  "https://github.com/permissionlessweb/cw-minus||cw-controllers|3.0.0"
  # cw-plus
  "https://github.com/permissionlessweb/cw-plus||cw20|3.0.0"
  "https://github.com/permissionlessweb/cw-plus||cw20-base|3.0.0"
  # cw-asset
  "https://github.com/permissionlessweb/cw-asset||cw-asset|4.0"
  # cw-plus-plus
  "https://github.com/permissionlessweb/cw-plus-plus||cw-address-like|3.0.1"
  "https://github.com/permissionlessweb/cw-plus-plus||cw-ownable|3.0.1"
  # cw-packages
  "https://github.com/permissionlessweb/cw-packages||cw-clearable|0.2.0"
  "https://github.com/permissionlessweb/cw-packages||cw-blob|0.2.0"
  # cw-orchestrator
  "https://github.com/permissionlessweb/cw-orchestrator||cw-orch|0.30.0"
  "https://github.com/permissionlessweb/cw-orchestrator||cw-orch-interchain|0.8.1"
  "https://github.com/permissionlessweb/cw-orchestrator||cw-orch-clone-testing|0.9.0"
  "https://github.com/permissionlessweb/cw-orchestrator||cw-orch-daemon|0.29.0"
  "https://github.com/permissionlessweb/cw-orchestrator||cw-orch-proto|0.9.0"
  "https://github.com/permissionlessweb/cw-orchestrator||cw-plus-orch|0.25.0"
  "https://github.com/permissionlessweb/cw-orchestrator||cw-orch-neutron-test-tube|0.2.0"
  "https://github.com/permissionlessweb/cw-orchestrator||cw-orch-osmosis-test-tube|0.5.0"
  # polytone (bump/cw3)
  "https://github.com/permissionlessweb/polytone|bump/cw3|cw-orch-polytone|6.0.1"
  "https://github.com/permissionlessweb/polytone|bump/cw3|polytone|2.0.0"
  "https://github.com/permissionlessweb/polytone|bump/cw3|polytone-note|5.0.0"
  # polytone (bump/cw3-evm)
  "https://github.com/permissionlessweb/polytone|bump/cw3-evm|evm-note|0.3.1"
  "https://github.com/permissionlessweb/polytone|bump/cw3-evm|polytone-evm|2.0.0"
  # osmosis-rust
  "https://github.com/permissionlessweb/osmosis-rust||osmosis-std|0.26.0"
  # cosmos-rust
  "https://github.com/CyberHoward/cosmos-rust.git|patch-1|xionrs|0.19.0-pre"
  "https://github.com/CyberHoward/cosmos-rust.git|patch-1|xion_sdk_proto|0.24.0-pre"
)

for entry in "${FORK_EXPECTATIONS[@]}"; do
  IFS='|' read -r expected_url expected_branch crate_name expected_version <<< "$entry"

  # Find Cargo.toml files that declare this crate (not in target/ dirs)
  matches=$(rg -l "^${crate_name}\\s*=" "$REPO_ROOT" \
    --glob '*/Cargo.toml' --glob '!**/target/**' 2>/dev/null || true)

  [ -z "$matches" ] && continue

  while IFS= read -r toml_file; do
    line=$(rg "^${crate_name}\\s*=" "$toml_file" 2>/dev/null | head -1)

    # Skip workspace = true references
    echo "$line" | grep -q 'workspace\s*=\s*true' && continue

    # Skip path-only references (local patches)
    if echo "$line" | grep -q 'path\s*=' && ! echo "$line" | grep -q 'git\s*='; then
      continue
    fi

    rel_path="${toml_file#$REPO_ROOT/}"

    # Check git URL present
    if ! echo "$line" | grep -q 'git\s*='; then
      echo "MISSING GIT: $rel_path"
      echo "  Crate:    $crate_name"
      echo "  Expected: git = \"$expected_url\""
      echo "  Got:      $line"
      echo ""
      ISSUES=$((ISSUES + 1))
      EXIT_CODE=1
      continue
    fi

    # Check correct git URL
    if ! echo "$line" | grep -q "$expected_url"; then
      echo "WRONG URL: $rel_path"
      echo "  Crate:    $crate_name"
      echo "  Expected: $expected_url"
      echo "  Got:      $line"
      echo ""
      ISSUES=$((ISSUES + 1))
      EXIT_CODE=1
    fi

    # Check branch if expected
    if [ -n "$expected_branch" ]; then
      if ! echo "$line" | grep -q "branch\s*=\s*\"$expected_branch\""; then
        echo "WRONG BRANCH: $rel_path"
        echo "  Crate:    $crate_name"
        echo "  Expected: branch = \"$expected_branch\""
        echo "  Got:      $line"
        echo ""
        ISSUES=$((ISSUES + 1))
        EXIT_CODE=1
      fi
    fi

    # Check version
    if ! echo "$line" | grep -q "version\s*=\s*\"[=]*${expected_version}\""; then
      echo "VERSION MISMATCH: $rel_path"
      echo "  Crate:    $crate_name"
      echo "  Expected: $expected_version"
      echo "  Got:      $line"
      echo ""
      ISSUES=$((ISSUES + 1))
      EXIT_CODE=1
    fi

  done <<< "$matches"
done

echo "---"
if [ $EXIT_CODE -eq 0 ]; then
  echo "All fork references are consistent."
else
  echo "Found $ISSUES issue(s). Fix the above and re-run."
fi

exit $EXIT_CODE
