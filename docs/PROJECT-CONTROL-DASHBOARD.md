# Aria Ecosystem — Stage 1 Project Control Dashboard

**Baseline:** 2026-11-16  
**Purpose:** One evidence-backed view of the five initiatives, their repositories, current work, blockers, and Stage 1 exit evidence.

## Operating principles

- Aria is the shared public-facing identity and coordination layer, not a product dependency.
- Janus OS and OmniVault remain independent products with separate data, release cycles, and documented interfaces.
- Janus-Omega-OS remains a distinct repository in the same Janus lineage until full ancestry/tree comparison is complete.
- Janus Community and the Multicolored Hat Society are separate independent community products and websites.
- Never call a capability complete because it appears in a README, mock UI, demo, or plan. Use evidence labels: implemented-and-tested, implemented-but-unverified, simulated/demo, stub/placeholder, or planned.
- No destructive repository consolidation, production deployment, release signing, domain purchase, or external-provider connection without separate approval.

## Portfolio status

| Initiative | Current repository / decision | Stage 1 evidence | Current blockers |
|---|---|---|---|
| Janus OS | [Wizardwalt/Janus-OS](https://github.com/Wizardwalt/Janus-OS) — recommended current protected-runtime engineering home (provisional) | Separate runtime/web binaries; protected Lua plugin sandbox; authenticated API foundation; runtime+web release CI; source-level runtime audit | Core Lua trust/failure policy, Lua memory/output quotas, end-to-end authorization/audit tests, ArchISO build/VM boot, real serial-device verification |
| Janus-Omega-OS lineage | [Wizardwalt/Janus-Omega-OS](https://github.com/Wizardwalt/Janus-Omega-OS) — preserved original lineage and separate repository | Original Janus-Omega identity, ArchISO/Pandora/module/manual history preserved; paired lineage reports prepared | Full Git ancestry and recursive file inventory; determine which unique assets should remain or be migrated; independent ArchISO verification |
| Aria | Implemented in [Wizardwalt/Janus-OS](https://github.com/Wizardwalt/Janus-OS), PR #10 | Constitution, ten-domain knowledge taxonomy, portable record schema, SQLite knowledge store, source-preserving ingestion, scoped retrieval, reviewed learning, owner memory and encrypted-memory implementation, authenticated APIs, read-only OmniVault snapshot contract | Live model provider/chat-context wiring, full semantic retrieval/evaluation, key lifecycle and recovery, live cross-app OmniVault gateway |
| OmniVault | [Wizardwalt/OmniVault-Android](https://github.com/Wizardwalt/OmniVault-Android) | Local-first Android Vault Engine; PR #1 reliability work; CI unit tests and debug APK passed | PR review/merge; physical-device install test; interruption/recovery tests; broader real-provider fixtures; encrypted backups are not implemented |
| Janus Community | Planned independent repository: `Wizardwalt/Janus-Community`; static prototype staged at `community-sites/janus-community/` in the Phase 1 branch | Charter, requirements, README, responsive landing-page prototype | Standalone repository creation and migration, governance/moderation implementation, CI, privacy/export/backup |
| Multicolored Hat Society | Planned independent repository: `Wizardwalt/Multicolored-Hat-Society`; static prototype staged at `community-sites/multicolored-hat-society/` in the Phase 1 branch | Six-community charter, requirements, README, responsive landing-page prototype | Standalone repository creation and migration, research moderation/disclosure process, CI, privacy/export/backup |

The portfolio contains five initiatives. Janus-OS and Janus-Omega-OS are two distinct repositories within the Janus product lineage, not two additional initiatives.

## Active pull requests and verification

### Janus OS
- [PR #12 — CI: build both runtime and web, Clippy, and formatting report](https://github.com/Wizardwalt/Janus-OS/pull/12). Latest workflow passed: Clippy, both cargo checks, workspace tests, frontend/shell checks, and release builds of both binaries. Workspace-wide rustfmt check reports pre-existing formatting drift and is currently a visible non-blocking warning.
- [PR #13 — Repository lineage report](https://github.com/Wizardwalt/Janus-OS/pull/13). Documentation CI passed.
- [PR #14 — Runtime reality audit](https://github.com/Wizardwalt/Janus-OS/pull/14). Documentation CI passed; includes the core-Lua startup/runtime integration gap.
- [Issue #11 — Janus Stage 1 release-readiness](https://github.com/Wizardwalt/Janus-OS/issues/11).

### Janus-Omega-OS
- [PR #5 — Phase 1 ecosystem foundation, community charters, and dashboard](https://github.com/Wizardwalt/Janus-Omega-OS/pull/5). CI passed on the latest inspected head.
- [PR #6 — Preserve Janus-Omega repository lineage](https://github.com/Wizardwalt/Janus-Omega-OS/pull/6). Documentation CI passed.
- [Issue #7 — Create the two independent community repositories](https://github.com/Wizardwalt/Janus-Omega-OS/issues/7).

### Aria
- [PR #10 — Aria knowledge architecture and integration contract](https://github.com/Wizardwalt/Janus-OS/pull/10). CI passed on the latest inspected head.
- [Issue #3 — Aria near-release readiness](https://github.com/Wizardwalt/Janus-Omega-OS/issues/3).

### OmniVault
- [PR #1 — Stage 1 vault reliability implementation](https://github.com/Wizardwalt/OmniVault-Android/pull/1). Unit tests and debug APK build passed on the inspected head.
- [PR #3 — Stage 1 vault reliability audit](https://github.com/Wizardwalt/OmniVault-Android/pull/3). Unit tests and debug APK assembly both passed.
- [Issue #2 — OmniVault release-readiness](https://github.com/Wizardwalt/OmniVault-Android/issues/2).

## Important architecture distinction

Aria's **ten internal knowledge hats** (Red, Orange, Yellow, Green, Blue, Purple, Black, White, Brown, Rainbow) are a classification/retrieval taxonomy.

The independent **Multicolored Hat Society** has **six communities** (White, Black, Gray, Blue, Red, Green). These are separate concepts and must not be merged into one registry or permission system.

## Next execution sequence

1. Complete full Git ancestry and recursive tree inventory; preserve unique Omega assets.
2. Close the highest-risk Janus runtime gaps: core Lua trust policy, sandbox resource limits, auth/audit integration tests.
3. Review OmniVault PR #1, install the APK on a physical device, and test interruption/recovery.
4. Consolidate Aria's host/API contract and build the real read-only OmniVault bridge only after authorization/revocation tests exist.
5. Create the two independent community repositories and migrate the staged static prototypes and approved charters into them.
6. Clean up repository-wide Rust formatting in a focused PR; keep the warning visible until the check is fully clean.
7. Keep a fresh CI/build/test record for each project; do not claim Stage 1 parity until every exit criterion is met.

## Limitations

This dashboard reports repository evidence and CI status observed during the current review. It does not claim physical-device validation, ISO boot validation, production deployment, encrypted OmniVault backups, live AI provider integration, or deployed community sites. The GitHub connector in this session does not expose repository creation; the community charters and names are ready, but the two standalone repositories still need to be created through GitHub's New repository flow.
