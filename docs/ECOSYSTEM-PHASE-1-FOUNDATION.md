# Aria Ecosystem — Phase 1 Foundation

**Status:** Planning baseline; not a release-readiness claim.  
**Purpose:** Establish clear product boundaries, ownership, integration rules, and Phase 1 acceptance criteria before expanding implementation.

## Vision

Aria is the recognizable AI identity and assistant experience connecting the ecosystem. Aria is not a reason to tightly couple the products: each product must remain useful when Aria or another connected service is unavailable.

The ecosystem has five distinct workstreams:

1. **Aria** — the assistant, identity, memory, learning, and integration layer.
2. **Janus OS** — the electronics, computing, device-servicing, and controlled technical-research platform.
3. **OmniVault** — the local-first, provider-independent archive and user-controlled knowledge vault.
4. **Janus Community** — an independent public technology community and knowledge-sharing website.
5. **Multicolored Hat Society** — a separate, independent cybersecurity education, research, and collaboration website.

Janus Community and the Multicolored Hat Society are separate websites and products. They may link to one another and to Janus OS, OmniVault, and Aria, but neither is merely a forum category inside the other.

## Product boundaries

| Workstream | Primary responsibility | Must remain independently useful |
|---|---|---|
| Aria | Assistant identity, memory, approved learning, tools, and integrations | Yes; provider-independent architecture and honest capability reporting |
| Janus OS | Device and electronics workflows, runtime, modules, and hardware interfaces | Yes; core workflows must not depend on community or cloud availability |
| OmniVault | Import, preserve, search, export, and permissioned access to user archives | Yes; local-first and not locked to Aria |
| Janus Community | General technology discussion, device knowledge, repair discoveries, and software/resource exchange | Yes; usable without Janus OS or Aria |
| Multicolored Hat Society | Structured cybersecurity education, research, challenges, and collaboration across six hat perspectives | Yes; usable without Janus OS or Aria |

## Shared identity and integration principles

- Use consistent Aria identity, approved artwork, tone, and product attribution across the ecosystem.
- Product branding may use **“Brought to you by Aria”** or **“Powered by Aria”** where accurate. Do not imply Aria is online or providing a feature when it is not.
- Each platform owns its own application data, authorization rules, operational health, and release process.
- Prefer documented, versioned APIs over direct database sharing.
- Use explicit, revocable, least-privilege grants for cross-product access.
- Never grant Aria blanket access to a user's OmniVault or community account by default.
- Community submissions are untrusted until reviewed. Preserve provenance and distinguish owner-tested, independently verified, experimental, failed, and deprecated material.
- Share sign-in only through a deliberately designed identity service; do not couple product availability to a single authentication or AI provider.
- A failure or outage in one platform must not take down the others.

## Multicolored Hat Society scope and safety

The Society has six distinct perspectives and learning tracks:

- **White Hat:** ethical security testing and protection.
- **Black Hat:** study of attacker behavior and malicious techniques for threat understanding and defense; no facilitation of real-world harm.
- **Gray Hat:** vulnerability research, authorization boundaries, and responsible disclosure.
- **Blue Hat:** defensive engineering, monitoring, incident response, and recovery.
- **Red Hat:** authorized adversary simulation and penetration testing.
- **Green Hat:** experimentation, programming, creative security engineering, and innovation.

Practical exercises must use owned systems, explicit authorization, or isolated labs. The platform should support responsible disclosure and defensive learning, not unauthorized access, credential theft, malware deployment, or harm to third parties.

## Website separation

- **Janus Community** gets its own website, repository, data store, moderation policies, and release pipeline.
- **Multicolored Hat Society** gets its own website, repository, data store, membership/community rules, learning content, and release pipeline.
- Both websites may provide reciprocal links and integrate with Aria through scoped APIs.
- The existing `website/` directory in Janus OS is not automatically either of these sites. Its current purpose must be audited before any reuse or migration.
- Domain names, hosting providers, and production deployment targets remain undecided until explicitly selected.

## Phase 1 — Foundation and baseline

### Work sequence

1. **Inventory existing work:** identify real code, tests, workflows, open PRs, demos, stubs, and documented limitations for Aria, Janus OS, and OmniVault.
2. **Record fresh verification:** capture current CI results and identify the latest tested commit for each repository. A previous green run is not proof that the current head passes.
3. **Protect in-flight work:** review open PRs and their checks before merging; do not bypass failing or pending checks.
4. **Establish product architecture:** use this document as the initial boundary contract; refine it only with evidence and explicit decisions.
5. **Scope the two websites:** create separate implementation plans and repositories for Janus Community and the Multicolored Hat Society after repository names and ownership are confirmed.
6. **Define shared contracts:** specify Aria identity, authentication boundaries, API versioning, permission grants, provenance, and service-degraded behavior before connecting products.
7. **Publish a parity board:** report each workstream as Not audited, In progress, Verified, Blocked, or Planned, with evidence and a next action.

### Phase 1 exit criteria

- All five workstreams have a named repository or an explicitly documented repository decision.
- Existing code is separated from plans, demos, simulated behavior, and unavailable capabilities.
- Current build/test/CI evidence is recorded per repository and commit.
- Open PRs and known blockers are inventoried; no unverified change is described as complete.
- Janus Community and Multicolored Hat Society have separate website scopes and are not folded into the Janus OS product site or one another.
- Cross-product identity and API boundaries are documented, including least-privilege and revocation requirements.
- A prioritized Phase 2 implementation backlog exists for each workstream.

## Current evidence and known caveats

- OmniVault has an open draft PR for Stage 1 vault reliability. Its own description says it is not merged and requires successful unit tests and debug APK assembly before sign-off. Backups are currently described as integrity-checked but not encrypted.
- Janus OS has existing web, runtime, TUI, and a `website/` directory. The README also documents simulated shell/ADB behavior and stubbed Lua APIs; these must not be represented as real device operations without code-level verification.
- Aria implementation is housed in the Janus OS repository according to the current project layout and must be audited separately from the Janus OS product.
- The two independent website repositories have not yet been established in this Phase 1 branch.
- This document is a planning and architecture artifact. It does not claim that builds, tests, integrations, or deployments have passed.

## Change control

Use focused branches and pull requests. Keep user data safe, avoid destructive migrations, preserve source archives, and require fresh CI plus review before merging release-critical changes. Production deployment, signing, external-provider connections, domain purchases, and changes to device firmware require separate explicit authorization.
