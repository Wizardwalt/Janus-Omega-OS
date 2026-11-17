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


## 2026-11-16 merge round — authoritative status update

The following pull requests have now been merged into their respective `main` branches:

- **Janus-OS:** #15 (plugin JSON bounds and Aria delivery gates), #10 (Aria knowledge architecture), #12 (runtime/web CI), #13 (repository lineage report), #14 (runtime reality audit), and #8 (encrypted append-only Aria memory journal).
- **Janus-Omega-OS:** #5 (ecosystem foundation/dashboard) and #6 (lineage preservation documentation).
- **OmniVault-Android:** #4 (restore negative tests and acceptance gates), #3 (Stage 1 audit), and #1 (vault reliability implementation).
- **Janus-Community:** #1 (local-only profile/discussion prototype).
- **Multicolored-Hat-Society:** #1 (local-only six-track profile/discussion prototype).

**Still open:** Janus-OS PR #6, “Add safe one-shot Janus recovery restore.” Its exact head SHA `62f5d394206bae9053b78229d4cf5a902956b332` has a failing `Build & Check` workflow: workspace checks pass, but workspace tests fail. It has not been merged. This is a concrete blocker to diagnose and fix before merging.

## Next three implementation steps per initiative

### Janus OS
1. Define a read-only, allowlisted trusted-core Lua module interface; do not share a mutable Lua VM with plugins.
2. Add a real VM memory/resource boundary (or isolated worker-process boundary), plus adversarial memory, instruction, JSON, output, and cancellation tests. The 256 KiB JSON limits are not a VM memory quota.
3. Add end-to-end authenticated API → plugin → audit tests, then reproduce and boot the actual ArchISO in a VM.

### Aria
1. Implement provider-neutral live adapters for one OpenAI-compatible remote provider and one local model, with server-side secrets and timeout/cancellation/rate/size limits.
2. Implement durable user-scoped conversation history, ownership enforcement, migrations, retention, export, and deletion; keep it separate from long-term memory.
3. Integrate provenance-linked, authorized memory retrieval into chat context with correction/review/deletion and read-only capability boundaries.

### OmniVault
1. Expand adversarial restore tests for duplicate/unreferenced entries, manifest errors, traversal, digest/size mismatch, truncated/oversized/ZIP-bomb inputs, and interruption recovery.
2. Design and implement a versioned authenticated-encryption backup format with vetted Android crypto APIs, key lifecycle/recovery/rotation, and wrong-key/tamper tests. Existing backups remain unencrypted until this is implemented.
3. Perform physical Android install/SAF/low-storage tests and verify byte-identical import → backup → restore → re-backup across app restarts.

### Janus Community
1. Decide and document production web/API/database architecture and privacy/threat model.
2. Implement real identity, sessions, account recovery, profile ownership, and privacy controls.
3. Implement shared discussions/replies plus reporting, moderation, appeals, rate limits, audit, backup, and recovery.

### Multicolored Hat Society
1. Decide and document production architecture and the authorized-lab safety model for all six communities.
2. Implement least-privilege identity, sessions, profile privacy, and role/lab authorization checks.
3. Implement persistent six-track discussions, human reporting/moderation/appeals, incident escalation, audit, backup, and recovery.

The community prototypes are still local-only; no production account, shared publishing, backend, or deployment is implied by the merges.

## Current unverified external acceptance

- Janus-OS PR #6 recovery restore remains blocked by failing workspace tests.
- No physical Android device acceptance has been performed for OmniVault.
- No physical serial hardware or ArchISO VM boot acceptance has been demonstrated.
- Aria live provider/chat-history wiring is not implemented yet.
- Community production authentication, persistence, moderation, privacy controls, and deployment are not implemented.


## 2026-11-17 follow-up — recovery and adversarial restore

- **Janus recovery:** PR #6 was closed without merging because its implementation is superseded by the newer recovery command already on Janus-OS `main`. The stale PR used unconditional DELETE statements against optional tables and its workspace tests failed. Current main checks table existence, clears applicable session/enrollment/trust tables, uses owner-only plaintext staging, and verifies SQLite integrity. [Closed superseded PR #6](https://github.com/Wizardwalt/Janus-OS/pull/6).
- **Janus regression coverage:** [PR #16](https://github.com/Wizardwalt/Janus-OS/pull/16) adds a partial-schema restore test: clear the session table when present, tolerate absent optional tables, and preserve unrelated application state. CI run [44040722746](https://github.com/Wizardwalt/Janus-OS/actions/runs/44040722746) was in progress at the last check; do not merge until complete.
- **OmniVault adversarial coverage:** [PR #5](https://github.com/Wizardwalt/OmniVault-Android/pull/5) adds a valid-manifest plus unreferenced-ZIP-entry attack fixture and asserts rejection without committing originals. CI run [44040727648](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44040727648) was in progress at the last check; do not merge until unit tests and APK assembly complete.

## Architecture decisions still gated

The next implementation gates for live Aria provider/history wiring, Janus trusted-core Lua and hard sandbox resource boundaries, OmniVault encrypted backup/key recovery, and production authentication/database/moderation for both communities require explicit architecture and threat-model decisions. No production stack, cryptographic/key-management scheme, Lua memory-isolation mechanism, external provider, or deployment target has been selected in this follow-up. These are not complete implementations. The five project issue trackers contain the acceptance sequences and blockers.


### Fresh verification update — 2026-11-17

- Janus-OS PR #16 is now **merged** to `main`. CI run [44040722746](https://github.com/Wizardwalt/Janus-OS/actions/runs/44040722746) passed Clippy, web/workspace cargo checks, all workspace tests, frontend/shell checks, release build, and binary existence checks. It adds partial-schema recovery coverage and confirms unrelated application state is preserved while existing session data is cleared.
- OmniVault PR #5 remains open while CI run [44040727648](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44040727648) completes. Unit tests passed; debug APK assembly was still running at the last check. Do not merge until APK assembly/upload and workflow completion succeed.


### Fresh verification update — 2026-11-17 (final)

- Janus-OS PR #16 merged to `main`; CI [44040722746](https://github.com/Wizardwalt/Janus-OS/actions/runs/44040722746) passed every job step, including Clippy, workspace tests, release build, and binary checks.
- OmniVault PR #5 merged to `main`; CI [44040727648](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44040727648) passed all unit tests, debug APK assembly, and artifact upload. It rejects unreferenced archive entries before originals are committed.
- The previous recovery PR #6 remains closed as superseded, not merged. Current main's recovery command is the maintained implementation.


## 2026-11-17 continuation — latest verified state

This section supersedes earlier status lines above wherever they conflict.

### Completed since the previous dashboard update

- **Janus-OS PR #16 is merged.** CI run [44040722746](https://github.com/Wizardwalt/Janus-OS/actions/runs/44040722746) completed successfully. It adds partial-schema recovery coverage and confirms that optional tables may be absent without breaking restore, existing sessions are invalidated, and unrelated application state is preserved.
- **OmniVault PR #5 is merged.** CI run [44040727648](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44040727648) completed successfully, including unit tests, debug APK assembly, and artifact upload. Restore rejects unreferenced ZIP archive entries before committing originals.
- **OmniVault PR #6 is now open:** [restore manifest metadata rejection](https://github.com/Wizardwalt/OmniVault-Android/pull/6). It adds tests for a mismatched aggregate byte count and an unsafe original filename, both asserting no original is committed. CI has not yet reported a run for this head; do not merge until it passes.

### Next implementation tracks — active work and gates

1. **Janus runtime safety:** inspect the current mlua memory-limit and worker-isolation options, then implement only after selecting the hard resource-boundary design. Keep plugin VMs separate from trusted-core state. Add authenticated API → plugin → audit integration coverage. Physical ArchISO/serial acceptance remains external.
2. **Aria:** select a provider-neutral adapter contract and a first remote/local provider pair; then add user-scoped conversation persistence, retention/export/deletion, and provenance-linked memory context. Keep model credentials server-side and all model/tool output untrusted. No live provider is connected yet.
3. **OmniVault:** continue adversarial restore tests (PR #6), then choose a portable encrypted-backup/key-recovery format before implementing encryption. Existing backup format omnivault.backup.v1 remains plaintext. Device install, Storage Access Framework, low-storage, and round-trip tests require a physical Android device and are not claimed complete.
4. **Janus Community and Multicolored Hat Society:** choose production hosting/API/database and identity architecture separately for each site, or explicitly approve a shared identity service with independent product authorization. Define privacy, deletion/export, moderation, appeals, audit, backup, and incident response before production accounts or publishing are enabled.

### Decisions required before production/security-sensitive implementation

- **Aria provider and history:** confirm first provider(s), whether local inference must work fully offline, where the runtime is hosted, and the required conversation retention/export/deletion policy.
- **OmniVault encryption:** choose whether backups must restore on a different device without the original Android Keystore. This determines whether portable passphrase-based key wrapping is required in addition to device-bound keys. No key scheme has been selected.
- **Janus sandbox:** choose a hard in-process Lua allocator limit only if supported and demonstrably enforced by the exact mlua/Lua build, or an isolated worker process with OS-enforced memory/CPU/time limits. JSON byte limits and instruction hooks are not memory isolation.
- **Community production stack:** choose hosting constraints, expected scale, account recovery model, and whether the two sites may share infrastructure. Their user databases, moderation policies, and authorization remain independent regardless.

### External acceptance still needed

A person with the Android device must install the generated debug APK and report results for first launch, import through the system file picker, backup to a user-selected SAF destination, restore from that destination, low-storage behavior, app restart, and byte-identical source verification. CI APK assembly is not a substitute for this test.


## 2026-11-17 execution update — regression coverage round

- **OmniVault PR #6** (test/restore-manifest-integrity-cases) initially failed unit-test compilation because a fixture parameter was substituted into the wrong test. The failed CI log identified the exact unresolved reference. The fixture was corrected in commit 3ea4690cc23c0efcedff79b30a29851bbb37f99f; a fresh Android build run [44042186455](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44042186455) is now running. The PR remains open and must not be merged until unit tests, APK assembly, and artifact upload pass.
- **Janus-OS PR #17** adds a regression test for rejecting excessively nested plugin result tables at the JSON conversion boundary. It does not claim to limit Lua heap memory or isolate the VM. CI run [44042252468](https://github.com/Wizardwalt/Janus-OS/actions/runs/44042252468) is running.
- **Janus-OS PR #18** adds Aria unified-retrieval coverage proving expired personal memories are excluded and source references remain attached to active memories. CI status is pending at this update.
- These are test-only changes. Live Aria provider/chat history, encrypted OmniVault backups, a hard Janus Lua resource boundary, and production community services remain unimplemented pending their respective design decisions and acceptance evidence.


## 2026-11-17 execution update — three regression PRs merged

This update supersedes the immediately preceding “regression coverage round” status above.

- **OmniVault PR #6 is merged** to `main` (merge commit `ce5b4d05b1b91838b89d2a215885f42b981027c8`). Android CI run [44042186455](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44042186455) passed unit tests, debug APK assembly, and artifact upload. The added tests cover manifest aggregate-byte-count mismatch and unsafe original filenames, asserting restore does not commit originals on failure.
- **Janus-OS PR #17 is merged** to `main` (merge commit `1f7026442bac6f61f91014086a350b59e0269ac2`). CI run [44042252468](https://github.com/Wizardwalt/Janus-OS/actions/runs/44042252468) passed Clippy, workspace checks/tests, frontend and shell checks, release build, and binary checks. The regression test confirms excessively nested plugin result tables are rejected at the JSON conversion boundary. This is not a Lua VM memory quota or process-isolation boundary.
- **Janus-OS PR #18 is merged** to `main` (merge commit `baadafc3aeb695bf65eb49f75d90b01a8296e102`). CI run [44042359954](https://github.com/Wizardwalt/Janus-OS/actions/runs/44042359954) passed the same workspace validation and release build. The test confirms expired personal memories are excluded from unified retrieval and source references remain attached to active results.
- No production provider, durable conversation history, portable encrypted backup, OS-enforced Lua resource isolation, or production community backend was introduced by these test-only merges.

### Next four bounded steps

1. Extend OmniVault restore tests for digest/size mismatch and truncated archives; preserve the invariant that no originals are committed until the entire archive is validated.
2. Add Janus plugin cancellation/timeout regression coverage at the existing public execution boundary; do not imply a hard CPU or heap quota.
3. Extend Aria retrieval tests for owner isolation and deterministic ranking/tie behavior, retaining provenance references.
4. Reconcile this dashboard against the live default branches and CI before selecting architecture-sensitive implementation work. The provider, encryption/key-recovery, sandbox-isolation, and production community-stack decisions remain gated; do not guess them.


## 2026-11-17 continuation — next regression round

The three previous regression PRs (#6 OmniVault, #17 Janus-OS, #18 Janus-OS) were merged after their CI workflows passed, as recorded above. This round opens three additional test-only PRs:

- **OmniVault PR #7 — truncated restore archive rejection:** [PR #7](https://github.com/Wizardwalt/OmniVault-Android/pull/7). Adds a truncated ZIP fixture and checks no original file is committed on rejection. Android CI run [44043253144](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44043253144) was in progress at the time of this update.
- **Janus-OS PR #19 — fresh plugin VM state isolation:** [PR #19](https://github.com/Wizardwalt/Janus-OS/pull/19). Verifies globals written in one plugin execution do not leak into the next. Janus CI run [44043257513](https://github.com/Wizardwalt/Janus-OS/actions/runs/44043257513) was in progress at the time of this update. This preserves the per-execution VM contract but does not claim OS process isolation or a hard heap quota.
- **Janus-OS PR #20 — deterministic Aria retrieval ties:** [PR #20](https://github.com/Wizardwalt/Janus-OS/pull/20). Verifies equal-score personal memory results use stable ID ordering and retain their individual source references. No workflow run was returned for this head at the time of this update; verify workflow dispatch/status before merge.

### Five-step execution record

1. Added a truncated-archive rejection test to OmniVault; awaiting Android CI.
2. Added a fresh-VM-per-execution isolation regression test to Janus; awaiting Janus CI.
3. Added deterministic equal-score retrieval ordering and provenance assertions to Aria; CI dispatch/status still needs confirmation.
4. Opened the three focused PRs against current `main`; none is merged at this update.
5. Updated this dashboard with the exact PRs, commit-level CI references, and remaining verification gates.

Do not merge any of these PRs until the exact head commit has a successful full workflow. A missing workflow result is not a pass. Continue to keep portable encrypted backup, live provider/history integration, OS-enforced Lua resource isolation, and production community infrastructure gated on their explicit architecture decisions.


### CI dispatch confirmation — 2026-11-17

- OmniVault PR #7 workflow [44043253144](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44043253144) is running; unit tests are in progress.
- Janus-OS PR #19 workflow [44043257513](https://github.com/Wizardwalt/Janus-OS/actions/runs/44043257513) is running; dependency/cache preparation is in progress.
- Janus-OS PR #20 workflow [44043265298](https://github.com/Wizardwalt/Janus-OS/actions/runs/44043265298) has now been dispatched and is running.
- All three PRs remain open. No merge is authorized until each corresponding exact-head workflow completes successfully.


## 2026-11-17 execution update — next regression round merged

The three follow-up regression PRs have now passed CI on their exact head commits and have been squash-merged:

- **OmniVault PR #7** — merge commit `dc12b119ee1cb7feca7b448de497ebce83b04cb5`; workflow [44043253144](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44043253144) passed unit tests, debug APK assembly, and artifact upload. The new test rejects a truncated ZIP restore and verifies no original archive is committed.
- **Janus-OS PR #19** — merge commit `e8d5757140e4a572ec8694e81cfa87a4e9bed28d`; workflow [44043257513](https://github.com/Wizardwalt/Janus-OS/actions/runs/44043257513) passed Clippy, workspace checks/tests, frontend and shell checks, release build, and binary checks. The test verifies a fresh Lua VM per plugin execution; it does not establish OS process isolation or a hard heap quota.
- **Janus-OS PR #20** — merge commit `cec50d9be5c4732e7ade1c335df05ccf124df7e8`; workflow [44043265298](https://github.com/Wizardwalt/Janus-OS/actions/runs/44043265298) passed the same full Janus checks. The test verifies deterministic equal-score personal-memory ordering and provenance references.

### Current verified project reality

- **Janus-OS:** protected runtime and test coverage are progressing. Lua executes in a fresh VM per plugin request with an instruction limit and 256 KiB JSON input/output limits. These controls do not impose an OS-enforced heap/CPU/time boundary. The public README confirms that live Aria chat remains scripted, and non-serial hardware drivers remain unsupported.
- **Aria:** the knowledge foundation, scoped stores, encrypted personal-memory implementation, ingestion/review flow, and retrieval tests exist in Janus-OS. Live model-provider wiring, durable user-scoped conversation history, chat-context integration, full semantic retrieval/evaluation, and host-managed key lifecycle remain incomplete. Do not confuse this with the separate Society's six tracks.
- **OmniVault:** local-first import, original preservation, SHA-256 fingerprinting, search, and staged/validated ZIP backup/restore exist. Backup ZIPs remain unencrypted. Physical Android install, SAF, low-storage, restart, and byte-identical round-trip testing remain outstanding.
- **Janus Community:** a standalone static prototype exists. Production identity, shared persistence, moderation/governance, privacy/export/backup, and deployment are not implemented.
- **Multicolored Hat Society:** a standalone six-track static prototype exists. Production identity, persistent discussions, moderation/reporting, authorized-lab governance, privacy/export/backup, and deployment are not implemented.
- **Janus-Omega-OS:** remains a separate lineage repository. Its README still contains legacy claims and simulated/stubbed capability descriptions; the protected-runtime README in Janus-OS is the more current operational contract. Full ancestry and recursive asset comparison remain outstanding.

### Next three portfolio steps

1. **Reconcile lineage and runtime truth:** complete a full Git ancestry and recursive tree comparison of Janus-Omega-OS versus Janus-OS; identify unique assets before any migration. Separately trace the Janus core-Lua startup path and authenticated API-to-plugin execution path so core modules are not described as connected until proven.
2. **Close the three highest-risk product gaps through explicit design decisions:** Janus OS needs an OS-enforced plugin worker/resource boundary; Aria needs a selected provider strategy and a durable owner-scoped conversation-history contract; OmniVault needs a versioned portable authenticated-encryption backup and key-recovery design. Do not implement these by guessing.
3. **Turn the two community prototypes into independently operable products:** document separate authorization, moderation, privacy, and data-retention policies; then select whether hosting infrastructure may be shared while keeping accounts, data, and governance independent. Implement only after those choices are recorded.

No physical-device validation, live AI provider integration, portable encrypted backup, OS-level plugin isolation, production community backend, or deployed website is claimed by this update.


## 2026-11-17 product implementation round

Five focused product changes have been opened; no PR is to be merged until its workflow passes on the exact head SHA.

| Product | Change | PR | Exact head | CI |
| --- | --- | --- | --- | --- |
| Aria / Janus OS | Explicit stable-ID tie-break for equal relevance scores across knowledge, source passages, and personal memories | [Janus-OS #21](https://github.com/Wizardwalt/Janus-OS/pull/21) | `4f84e5368adfacd69973364139995b85c680ce85` | Run [44195516304](https://github.com/Wizardwalt/Janus-OS/actions/runs/44195516304): workspace tests passed; release build still running at last check |
| Janus runtime | Run bounded synchronous Lua execution on Tokio blocking pool; stop logging raw plugin arguments | [Janus-OS #22](https://github.com/Wizardwalt/Janus-OS/pull/22) | `496778abc785397ffae3cfae3b3f198a9e37bb2b` | Run [44195587578](https://github.com/Wizardwalt/Janus-OS/actions/runs/44195587578): workspace tests passed; release build still running at last check |
| OmniVault | Provider filter chips combined with text search; pure filtering helper and unit tests | [OmniVault #8](https://github.com/Wizardwalt/OmniVault-Android/pull/8) | `b9680d4c3e75f92d31b4d359ff2ac4d378f67937` | Run [44195694958](https://github.com/Wizardwalt/OmniVault-Android/actions/runs/44195694958): unit tests running at last check |
| Janus Community | Correct malformed nested style element in the prototype page | [Janus Community #3](https://github.com/Wizardwalt/janus-community/pull/3) | `3ae680f8e33fd8b18484298132ee8c19d60c2a01` | Run [44195765955](https://github.com/Wizardwalt/janus-community/actions/runs/44195765955): passed |
| Multicolored Hat Society | Correct malformed nested style element in the prototype page | [Society #3](https://github.com/Wizardwalt/multicolored-hat-society/pull/3) | `751a5e58accfbcef957465935879563c8eafbb00` | Run [44195779775](https://github.com/Wizardwalt/multicolored-hat-society/actions/runs/44195779775): queued at last check |

### Implementation notes and limits

- Aria retrieval remains lexical relevance scoring; this change makes tie order explicit but does not add semantic/vector retrieval.
- Janus blocking-pool execution protects Tokio async worker scheduling and avoids logging user-supplied arguments. It is not OS process isolation and does not add hard memory or wall-clock limits.
- OmniVault provider filtering is an on-device browsing feature. It does not alter originals or backup format.
- The community and Society changes repair malformed HTML/CSS markup only. Both remain local-only prototypes without production accounts, shared publishing, or server persistence.

The next code-focused work should continue with real device validation and the protected runtime's actual execution path. Do not begin production backend deployment until the account, authorization, privacy, moderation, and hosting decisions are approved.
