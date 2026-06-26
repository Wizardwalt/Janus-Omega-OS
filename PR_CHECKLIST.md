# PR Checklist

## Summary
This branch restructures Janus Omega into a modular platform foundation with:

- Rust workspace crates:
  - janus-core
  - janus-runtime
  - janus-tui
  - janus-web
- manifest-based plugin discovery
- runtime API
- audit logging
- assistant state and chat memory
- notes/evidence/export scaffolding
- Android launcher/operator scaffold

## Verify
- [ ] `cargo check` passes
- [ ] `cargo run -p janus-runtime` starts
- [ ] `/health` returns `ok`
- [ ] `/api/status` works
- [ ] `/api/modules` works
- [ ] `/api/assistant/chat` works
- [ ] `/api/notes` works
- [ ] `/api/evidence` works
- [ ] Android scaffold files exist under `android/`

## Follow-up work
- [ ] Real JSON parsing on Android
- [ ] Android assistant chat UI
- [ ] Android notes/evidence creation UI
- [ ] Mode switching UI on Android
- [ ] HAL/peripheral abstraction
- [ ] Recovery environment
- [ ] Secure storage/encryption improvements
