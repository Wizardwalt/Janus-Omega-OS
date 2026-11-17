# Independent Community Platform Requirements

**Applies to:** Janus Community and Multicolored Hat Society  
**Status:** Stage 1 platform architecture baseline; no production sites or repositories are claimed.

## Non-negotiable separation

Each community receives its own:
- Git repository and release history;
- website and application configuration;
- data store and backup/restore process;
- membership and authorization rules;
- moderation team, policies, and appeals process;
- terms, privacy notice, retention and deletion rules;
- issue tracker, contribution process, and CI pipeline.

They may link to one another and to Janus OS, OmniVault, and Aria. They must not be implemented as two categories in one shared community application.

## Shared design principles

- Mobile-first, accessible, responsive web experience.
- Clear public/private boundaries and minimal personal-data collection.
- Moderation, reporting, rate limits, and abuse prevention designed before public launch.
- Searchable, source-attributed technical knowledge with correction and version history.
- Exportable user contributions and documented data formats.
- Automated tests, dependency review, security scanning, backups, and recovery drills.
- Clear labels for experimental, unverified, simulated, and independently tested content.
- Graceful operation when Aria or an external provider is unavailable.

## Aria integration boundary

Aria integration is optional and permissioned. A community can operate without Aria. Aria receives only the content required for a user-approved task. Private messages, account data, moderation records, and unpublished submissions are not available by default. Revocation must stop future access.

## Initial platform components

1. Public landing page and project explanation.
2. Community charter, conduct rules, and safety policies.
3. Account and profile layer with minimal data collection.
4. Topic/track organization, search, and content discovery.
5. Contribution, editing, attribution, and revision history.
6. Reporting, moderation queue, appeals, and admin audit log.
7. Documentation and learning resources.
8. Backup/export and user data deletion workflow.
9. CI checks, deployment configuration, monitoring, and incident response.

## Explicitly not decided

No domain names, hosting provider, authentication vendor, database, framework, payment system, or production deployment target is selected by this document. Those choices require a separate technical decision and approval. The two independent repositories still need to be created; this foundation document does not claim that they already exist.
