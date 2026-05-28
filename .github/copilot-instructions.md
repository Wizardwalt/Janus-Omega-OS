# Copilot Coding Agent Instructions

This project is a cross-platform OS emulator built with Tauri, Rust, and Lua.

## Coding Policies

- All new Lua modules **must prioritize battery efficiency**. Local logic should avoid spinning loops, unnecessary polling, and always prefer event-based operations where possible. Fallbacks for network or hardware calls must minimize power usage.
- Rust should be used **only** for core system processes and RAM/state management (including the secure snapshot/restore functionality), not for UI or plugin logic.
- If writing plugins or modules for the 'Overseer AI', you must support a **tiered offline/online mode**:
  - Offline: Only allow pattern matching, local scripts, or basic responses (do not call LLM or load heavy AI models when the device is network-disconnected).
  - Online: Use a lightweight external LLM API or cloud service for advanced reasoning, only when a network connection is active.
- All modules/plugins must be designed for cross-platform compatibility and work seamlessly with Tauri's event system.

> Please do not propose or auto-insert high-power or cloud-dependent code into Lua modules for offline scenarios. 