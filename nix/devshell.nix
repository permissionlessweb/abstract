{ pkgs, forkRegistry }:

let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" "rust-analyzer" "clippy" ];
    targets = [ "wasm32-unknown-unknown" ];
  };

  forkListScript = pkgs.writeShellScriptBin "fork-list"
    (builtins.readFile ./scripts/fork-list.sh);

  forkValidateScript = pkgs.writeShellScriptBin "fork-validate"
    (builtins.readFile ./scripts/fork-validate.sh);

  forkUpdateScript = pkgs.writeShellScriptBin "fork-update"
    (builtins.readFile ./scripts/fork-update.sh);

in
pkgs.mkShell {
  name = "abstract-dev";

  nativeBuildInputs = [
    # Rust toolchain
    rustToolchain

    # Build dependencies
    pkgs.pkg-config
    pkgs.openssl

    # Dev tools
    pkgs.just
    pkgs.taplo       # TOML formatter/linter
    pkgs.jq          # JSON processing (used by fork scripts)
    pkgs.ripgrep     # Search (used by fork-validate)

    # Fork management
    forkListScript
    forkValidateScript
    forkUpdateScript
  ];

  RUST_BACKTRACE = "1";

  shellHook = ''
    echo "========================================"
    echo " Abstract CosmWasm Dev Shell"
    echo " cosmwasm-std v3.0.1 migration"
    echo "========================================"
    echo "Rust:  $(rustc --version)"
    echo "Cargo: $(cargo --version)"
    echo ""
    echo "Fork management:"
    echo "  fork-list       List all pinned forks and their commits"
    echo "  fork-validate   Check Cargo.toml fork consistency"
    echo "  fork-update     Update a fork (e.g. fork-update cw-plus)"
    echo ""
    echo "Workspaces: framework/ modules/ integrations/ interchain/"
    echo "========================================"
  '';
}
