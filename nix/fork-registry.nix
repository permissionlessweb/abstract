# Fork Registry — single source of truth for all forked dependencies
#
# Each entry maps a flake input to the crates it provides, the Git URL
# as it appears in Cargo.toml, the branch (null = default), and where
# the dependency is expected to be declared.
#
# The fork-validate script uses this data to check Cargo.toml consistency.

{ inputs }:

{
  forks = {

    # ── permissionlessweb forks ──────────────────────────────────────────

    cw-minus = {
      input = inputs.fork-cw-minus;
      gitUrl = "https://github.com/permissionlessweb/cw-minus";
      branch = null;
      crates = [
        { name = "cw-controllers"; version = "3.0.0"; }
      ];
      expectedInWorkspaces = [ "framework" "modules" "integrations" "interchain" ];
    };

    cw-plus = {
      input = inputs.fork-cw-plus;
      gitUrl = "https://github.com/permissionlessweb/cw-plus";
      branch = null;
      crates = [
        { name = "cw20"; version = "3.0.0"; }
        { name = "cw20-base"; version = "3.0.0"; }
      ];
      expectedInWorkspaces = [ "framework" "modules" "integrations" "interchain" ];
    };

    cw-asset = {
      input = inputs.fork-cw-asset;
      gitUrl = "https://github.com/permissionlessweb/cw-asset";
      branch = null;
      crates = [
        { name = "cw-asset"; version = "4.0"; }
      ];
      expectedInWorkspaces = [ "framework" "modules" "integrations" "interchain" ];
    };

    cw-plus-plus = {
      input = inputs.fork-cw-plus-plus;
      gitUrl = "https://github.com/permissionlessweb/cw-plus-plus";
      branch = null;
      crates = [
        { name = "cw-address-like"; version = "3.0.1"; }
        { name = "cw-ownable"; version = "3.0.1"; }
      ];
      expectedInWorkspaces = [ "framework" "modules" "integrations" "interchain" ];
    };

    cw-packages = {
      input = inputs.fork-cw-packages;
      gitUrl = "https://github.com/permissionlessweb/cw-packages";
      branch = null;
      crates = [
        { name = "cw-clearable"; version = "0.2.0"; }
        { name = "cw-blob"; version = "0.2.0"; }
      ];
      expectedInWorkspaces = [ "framework" ];
    };

    cw-orchestrator = {
      input = inputs.fork-cw-orchestrator;
      gitUrl = "https://github.com/permissionlessweb/cw-orchestrator";
      branch = null;
      crates = [
        { name = "cw-orch"; version = "0.30.0"; }
        { name = "cw-orch-interchain"; version = "0.8.1"; }
        { name = "cw-orch-clone-testing"; version = "0.9.0"; }
        { name = "cw-orch-daemon"; version = "0.29.0"; }
        { name = "cw-orch-proto"; version = "0.9.0"; }
        { name = "cw-plus-orch"; version = "0.25.0"; }
        { name = "cw-orch-neutron-test-tube"; version = "0.2.0"; }
        { name = "cw-orch-osmosis-test-tube"; version = "0.5.0"; }
      ];
      expectedInWorkspaces = [ "framework" "modules" "integrations" "interchain" ];
    };

    polytone-cw3 = {
      input = inputs.fork-polytone-cw3;
      gitUrl = "https://github.com/permissionlessweb/polytone";
      branch = "bump/cw3";
      crates = [
        { name = "cw-orch-polytone"; version = "6.0.1"; }
        { name = "polytone"; version = "2.0.0"; }
        { name = "polytone-note"; version = "5.0.0"; }
      ];
      expectedInWorkspaces = [ "framework" ];
    };

    polytone-cw3-evm = {
      input = inputs.fork-polytone-cw3-evm;
      gitUrl = "https://github.com/permissionlessweb/polytone";
      branch = "bump/cw3-evm";
      crates = [
        { name = "evm-note"; version = "0.3.1"; }
        { name = "polytone-evm"; version = "2.0.0"; }
      ];
      expectedInWorkspaces = [];
      expectedInCrates = [
        "framework/contracts/native/ica-client/Cargo.toml"
        "framework/packages/abstract-ica/Cargo.toml"
      ];
    };

    osmosis-rust = {
      input = inputs.fork-osmosis-rust;
      gitUrl = "https://github.com/permissionlessweb/osmosis-rust";
      branch = null;
      crates = [
        { name = "osmosis-std"; version = "0.26.0"; }
      ];
      expectedInWorkspaces = [];
      expectedInCrates = [
        "integrations/osmosis-adapter/Cargo.toml"
        "modules/contracts/adapters/dex/Cargo.toml"
      ];
    };

    # ── Other forks ──────────────────────────────────────────────────────

    cosmos-rust = {
      input = inputs.fork-cosmos-rust;
      gitUrl = "https://github.com/CyberHoward/cosmos-rust.git";
      branch = "patch-1";
      crates = [
        { name = "xionrs"; version = "0.19.0-pre"; }
        { name = "xion_sdk_proto"; version = "0.24.0-pre"; }
      ];
      expectedInWorkspaces = [];
      expectedInCrates = [
        "framework/contracts/account/Cargo.toml"
        "interchain/scripts/Cargo.toml"
      ];
    };

    wynddex = {
      input = inputs.fork-wynddex;
      gitUrl = "https://github.com/abstractsdk/wynddex";
      branch = null;
      rev = "cbe316f17c4a89d0c3938ea66747a5ff1fc5a5e9";
      crates = [
        { name = "wyndex"; version = "2.2.0"; }
        { name = "wyndex-factory"; version = "2.2.0"; }
        { name = "wyndex-multi-hop"; version = "2.2.0"; }
        { name = "wyndex-pair"; version = "2.2.0"; }
        { name = "wyndex-stake"; version = "2.2.0"; }
      ];
      expectedInWorkspaces = [];
      expectedInCrates = [
        "integrations/bundles/mockdex/Cargo.toml"
      ];
    };
  };

  # ── Workspace layout reference ──────────────────────────────────────
  #
  # abstract/
  # +-- framework/           Workspace root: core SDK packages + contracts
  # |   +-- packages/
  # |   |   +-- abstract-adapter/
  # |   |   +-- abstract-app/
  # |   |   +-- abstract-client/
  # |   |   +-- abstract-ica/
  # |   |   +-- abstract-integration-tests/
  # |   |   +-- abstract-interface/
  # |   |   +-- abstract-macros/
  # |   |   +-- abstract-sdk/
  # |   |   +-- abstract-standalone/
  # |   |   +-- abstract-std/
  # |   |   +-- abstract-testing/
  # |   |   +-- standards/
  # |   |       +-- dex/
  # |   |       +-- money-market/
  # |   |       +-- staking/
  # |   |       +-- utils/
  # |   +-- contracts/
  # |       +-- account/
  # |       +-- native/
  # |           +-- ans-host/
  # |           +-- ibc-client/
  # |           +-- ibc-host/
  # |           +-- ica-client/
  # |           +-- module-factory/
  # |           +-- registry/
  # |
  # +-- modules/             Workspace root: abstract-maintained modules
  # |   +-- contracts/
  # |       +-- adapters/
  # |       |   +-- cw-staking/
  # |       |   +-- dex/
  # |       |   +-- money-market/
  # |       +-- apps/
  # |           +-- challenge/
  # |
  # +-- integrations/        Workspace root: chain-specific adapters
  # |   +-- astrovault-adapter/
  # |   +-- kujira-adapter/
  # |   +-- neutron-dex-adapter/
  # |   +-- osmosis-adapter/
  # |   +-- wyndex-adapter/
  # |   +-- bundles/
  # |       +-- mockdex/
  # |
  # +-- interchain/          Workspace root: IBC testing + deployment scripts
  # |   +-- scripts/
  # |   +-- interchain-end_to_end_testing/
  # |   +-- framework-clone-testing/
  # |   +-- modules-clone-testing/
  # |
  # +-- nix/                 Nix environment (this directory)
  #     +-- devshell.nix
  #     +-- fork-registry.nix
  #     +-- scripts/
  #         +-- fork-list.sh
  #         +-- fork-validate.sh
  #         +-- fork-update.sh
}
