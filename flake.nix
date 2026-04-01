{
  description = "Abstract CosmWasm monorepo - v3 migration dev environment";

  inputs = {
    # ── Nix infrastructure ──────────────────────────────────────────────
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

    # ── permissionlessweb forks (cosmwasm-std v3 compat) ────────────────
    # Each is `flake = false` — Nix fetches the source tree and pins the
    # exact commit in flake.lock without requiring a flake.nix in the repo.

    # cw-controllers v3.0.0
    fork-cw-minus = {
      url = "github:permissionlessweb/cw-minus";
      flake = false;
    };

    # cw20 v3.0.0, cw20-base v3.0.0
    fork-cw-plus = {
      url = "github:permissionlessweb/cw-plus";
      flake = false;
    };

    # cw-asset v4.0
    fork-cw-asset = {
      url = "github:permissionlessweb/cw-asset";
      flake = false;
    };

    # cw-address-like v3.0.1, cw-ownable v3.0.1
    fork-cw-plus-plus = {
      url = "github:permissionlessweb/cw-plus-plus";
      flake = false;
    };

    # cw-clearable v0.2.0, cw-blob v0.2.0
    fork-cw-packages = {
      url = "github:permissionlessweb/cw-packages";
      flake = false;
    };

    # cw-orch v0.30.0, cw-orch-interchain v0.8.1, + 6 more crates
    fork-cw-orchestrator = {
      url = "github:permissionlessweb/cw-orchestrator";
      flake = false;
    };

    # cw-orch-polytone v6.0.1, polytone v2.0.0, polytone-note v5.0.0
    fork-polytone-cw3 = {
      url = "github:permissionlessweb/polytone/bump/cw3";
      flake = false;
    };

    # evm-note v0.3.1, polytone-evm v2.0.0
    fork-polytone-cw3-evm = {
      url = "github:permissionlessweb/polytone/bump/cw3-evm";
      flake = false;
    };

    # osmosis-std v0.26.0
    fork-osmosis-rust = {
      url = "github:permissionlessweb/osmosis-rust";
      flake = false;
    };

    # ── Other forks ─────────────────────────────────────────────────────

    # xionrs (cosmrs) v0.19.0-pre, xion_sdk_proto v0.24.0-pre
    fork-cosmos-rust = {
      url = "github:CyberHoward/cosmos-rust/patch-1";
      flake = false;
    };

    # wyndex, wyndex-factory, wyndex-pair, wyndex-stake, wyndex-multi-hop
    fork-wynddex = {
      url = "github:abstractsdk/wynddex";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        forkRegistry = import ./nix/fork-registry.nix { inherit inputs; };
        devShell = import ./nix/devshell.nix { inherit pkgs forkRegistry; };
      in
      {
        devShells.default = devShell;

        # Expose fork registry for scripts / CI
        lib.forkRegistry = forkRegistry;
      }
    );
}
