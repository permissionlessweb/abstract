# Build everything
build:
  cargo build --all-features

# Test everything
test:
  cargo nextest run

watch-test:
  cargo watch -x "nextest run"

format:
  cargo fmt --all

lint:
  cargo clippy --all -- -D warnings

lintfix:
  cargo clippy --fix --allow-staged --allow-dirty --all-features
  just format

refresh:
  cargo clean && cargo update

check-codecov:
  cat codecov.yml | curl --data-binary @- https://codecov.io/validate

tag:
  set -e
  git tag v`grep -A1 "\[workspace.package\]" Cargo.toml | awk -F'"' '/version/ {print $2}'`
  git push origin v`grep -A1 "\[workspace.package\]" Cargo.toml | awk -F'"' '/version/ {print $2}'`

watch:
  cargo watch -x lcheck

check:
  cargo check --all-features

# `just wasm-contract template --features export,terra --no-default-features`
wasm-contract module +args='':
  RUSTFLAGS='-C link-arg=-s' cargo wasm --package {{module}}-app {{args}}

# Wasm all the contracts in the repository for the given chain
wasm chain_name:
  just wasm-contract template --features export --no-default-features

# Deploy your module to the chain
# ??? deploy-module module +args='': (wasm-module module)
# `just deploy-module dex pisco-1`
deploy-contract module network +args='':
  cargo deploy --package {{module}}-app -- --network-id {{network}} {{args}}

# Deploy all the apis
deploy network +args='':
  just wasm-contract template
  just deploy-contract template {{network}}

# Transfer the schemas to the Abstract schemas repo.
# TODO: git
publish-schemas version:
  SCHEMA_OUT_DIR=$(cd ../schemas && echo "$PWD") \
  VERSION={{version}} \
    cargo ws exec --no-bail bash -lc 'cargo schema && { outdir="$SCHEMA_OUT_DIR/abstract/${PWD##*/}/$VERSION"; mkdir -p "$outdir"; rm -rf "schema/raw"; cp -a "schema/." "$outdir"; }'
