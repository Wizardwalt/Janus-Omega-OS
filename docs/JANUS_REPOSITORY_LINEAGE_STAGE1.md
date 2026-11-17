# Janus-Omega-OS Repository Lineage — Stage 1

Janus-Omega-OS remains a distinct repository and the preserved original Janus-Omega project lineage. It is not being renamed, deleted, merged, or treated as interchangeable with `Wizardwalt/Janus-OS`.

The current Stage 1 working recommendation is to place new protected-runtime engineering in `Wizardwalt/Janus-OS`, whose default branch contains the newer split `janus-runtime` + `janus-web` architecture, authenticated runtime API, restricted production Lua sandbox, and explicit demo-vs-production labels.

This recommendation is provisional. Both repositories share Rust workspace/crate names and closely related README architecture; the Janus-OS workspace manifest still names Janus-Omega-OS as its Cargo repository URL. However, a complete Git ancestry and recursive tree comparison has not yet been completed. Similar manifests and branch names are not proof of shared commit history.

## Preserve in this repository

- Original Janus-Omega-OS project name and provenance.
- Arch Linux / archiso live-environment work and its build history.
- Pip-Boy / Pandora hardware documentation and design assets.
- Original module library, manuals, and lore.
- Distinct branches, commits, issues, and pull requests.

## Stage 1 rules

1. Do not force-push, rename, delete, or merge this repository into Janus-OS.
2. Do not bulk-copy files to Janus-OS.
3. Inventory ArchISO, Pandora hardware, manuals, modules, and unique project assets.
4. Verify build and boot claims independently; README statements are not test evidence.
5. Migrate any selected asset only through a reviewed, provenance-preserving change with tests.

## Paired evidence report

The companion evidence report is maintained in [Janus-OS](https://github.com/Wizardwalt/Janus-OS/blob/main/docs/audits/JANUS_REPOSITORY_LINEAGE_STAGE1.md).

## Current classification

- **Janus-OS:** recommended Stage 1 protected-runtime engineering home, pending full ancestry/tree verification.
- **Janus-Omega-OS:** preserved original Janus-Omega lineage and separate source of ArchISO, hardware, module, documentation, and project-history material.
- **Final repository ownership:** not declared until the complete ancestry and recursive inventory are reviewed.
