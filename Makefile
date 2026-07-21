run:
	cargo run --bin janus-web

release:
	cargo build --release --bin janus-web

check:
	cargo check --bin janus-web

clean:
	cargo clean

watch:
	cargo watch -x 'run --bin janus-web'

inventory:
	./scripts/validate-modules.sh

.PHONY: run release check clean watch inventory
