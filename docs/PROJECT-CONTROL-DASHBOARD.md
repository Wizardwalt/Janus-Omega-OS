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
| Janus OS | [Wizardwalt/Janus-OS](https://github.com/Wizardwalt/Janus-OS) — recommended current protected-runtime engineering home (provisional) | Separate runtime/web binaries; protected Lua plugin sandbox; authenticated API foundation; PR #15 adds 256 KiB JSON input/output limits and regression tests; latest Janus CI passed | Hard Lua VM memory quota, core Lua trust/failure policy, end-to-end authorization/audit tests, ArchISO build/VM boot, real serial-device verification |
| Janus-Omega-OS lineage | [Wizardwalt/Janus-Omega-OS](https://github.com/Wizardwalt/Janus-Omega-OS) — preserved original lineage and separate repository | Original Janus-Omega identity, ArchISO/Pandora/module/manual history preserved; paired lineage reports prepared | Full Git ancestry and recursive file inventory; determine which unique assets should remain or be migrated; independent ArchISO verification |
| Aria | Implemented in [Wizardwalt/Janus-OS](https://github.com/Wizardwalt/Janus-OS), PR #10; delivery gates in PR #15 | Existing knowledge architecture; PR #15 adds explicit acceptance gates for live provider adapter, user-scoped conversation history, and evidence-linked memory retrieval | Live model provider/chat-context wiring, full semantic retrieval/evaluation, key lifecycle and recovery, live cross-app OmniVault gateway |
| OmniVault | [Wizardwalt/OmniVault-Android](https://github.com/Wizardwalt/OmniVault-Android) | Local-first Android Vault Engine; PR #1 reliability work; PR #4 adds malformed/missing-manifest restore tests and Stage 1 restore/encryption/device acceptance gates; CI pending on latest PR #4 head | PR review/merge; physical-device install test; broader adversarial restore/recovery fixtures; encrypted backups are not implemented |
| Janus Community | [Wizardwalt/Janus-Community](https://github.com/Wizardwalt/Janus-Community) — standalone private repository | Static landing page; local-only profile preview, discussion composer, topic-filtered discussion board prototype; [PR #1](https://github.com/Wizardwalt/janus-community/pull/1) CI passed | Production authentication, shared persistence, governance/moderation, privacy/export/backup, deployment decision |
| Multicolored Hat Society | [Wizardwalt/Multicolored-Hat-Society](https://github.com/Wizardwalt/Multicolored-Hat-Society) — standalone private repository | Six-community landing page; local-only profile preview, six-track discussion composer, topic-filtered board; [PR #1](https://github.com/Wizardwalt/multicolored-hat-society/pull/1) CI passed | Production authentication, shared persistence, research moderation/disclosure, privacy/export/backup, deployment decision |

The portfolio contains five initiatives. Janus-OS and Janus-Omega-OS are two distinct repositories within the Janus product lineage, not two additional initiatives.

## Active pull requests and verification

### Janus OS
- [PR #15 — Plugin JSON input/output bounds and Aria delivery gates](https://github.com/Wizardwalt/Janus-OS/pull/15). Latest JanusOS CI passed, including workspace checks/tests and release build.
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
- [PR #4 — Restore negative tests and Stage 1 acceptance gates](https://github.com/Wizardwalt/OmniVault-Android/pull/4). CI was still running at the last check; the unit-test step had started. Do not call it passed until the workflow completes.
- [PR #1 — Stage 1 vault reliability implementation](https://github.com/Wizardwalt/OmniVault-Android/pull/1). Unit tests and debug APK build passed on the inspected head.
- [PR #3 — Stage 1 vault reliability audit](https://github.com/Wizardwalt/OmniVault-Android/pull/3). Unit tests and debug APK assembly both passed.
- [Issue #2 — OmniVault release-readiness](https://github.com/Wizardwalt/OmniVault-Android/issues/2).

## Important architecture distinction

Aria's **ten internal knowledge hats** (Red, Orange, Yellow, Green, Blue, Purple, Black, White, Brown, Rainbow) are a classification/retrieval taxonomy.

The independent **Multicolored Hat Society** has **six communities** (White, Black, Gray, Blue, Red, Green). These are separate concepts and must not be merged into one registry or permission system.

## Next execution sequence

1. Complete full Git ancestry and recursive tree inventory; preserve unique Omega assets.
2. Close the highest-risk Janus runtime gaps: core Lua trust policy, sandbox resource limits, auth/audit integration tests.
3. Finish OmniVault PR #4 CI, expand adversarial restore/recovery tests, then install the APK on a physical device.
4. Implement Aria's provider adapter and user-scoped conversation storage against PR #15's acceptance gates; build the real read-only OmniVault bridge only after authorization/revocation tests exist.
5. Review the community experience PRs; then decide the production auth/database architecture and implement authentication, persistent content, moderation/reporting, privacy/export/backup, and deployment foundations independently in each repository.
6. Clean up repository-wide Rust formatting in a focused PR; keep the warning visible until the check is fully clean.
7. Keep a fresh CI/build/test record for each project; do not claim Stage 1 parity until every exit criterion is met.

## Limitations

This dashboard reports repository evidence and CI status observed during the current review. It does not claim physical-device validation, ISO boot validation, production deployment, encrypted OmniVault backups, live AI provider integration, or deployed community sites. The two community repositories exist and their initial static-site and local-only profile/discussion prototype checks have passed. The new prototype PRs remain open; production authentication, shared persistence, moderation, privacy/export/backup, and deployment are not implemented.
