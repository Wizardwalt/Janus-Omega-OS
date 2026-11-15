# Janus Capability Expansion Architecture

## Purpose

Janus is an expandable computing platform whose abilities grow over time through software modules, supported hardware, and community contributions. It is never considered feature-complete. New capabilities must be discoverable, installable, permissioned, testable, and removable without destabilizing the core system.

This architecture applies across Pandora Titan, Janus Monolith, Janus OS, and Aria.

## Four expansion paths

1. **Software modules:** independently versioned tools, protocol support, workflows, integrations, and UI extensions.
2. **Hardware modules:** supported radios, antenna systems, sensors, storage, compute accelerators, wired interfaces, and daughterboards.
3. **Community extensions:** third-party modules distributed through trusted catalogs or installed from explicitly trusted sources.
4. **Aria skills and integrations:** capability-aware workflows that let Aria explain and coordinate installed tools through declared APIs and granted permissions.

A module may add software functionality, expose newly connected hardware, or both. Software must never claim a hardware capability that is absent, unsupported, disabled, or unverified.

## Core services

These are architectural responsibilities, not claims that every service is already implemented:

- **Capability Registry:** authoritative inventory of available capabilities, providers, versions, status, hardware dependencies, and support tier.
- **Hardware Discovery Service:** detects supported buses and attached devices, identifies known hardware, and reports unknown devices without automatically executing code or changing device state.
- **Module Manager:** validates, installs, updates, disables, removes, and rolls back modules.
- **Manifest and Compatibility Validator:** checks schemas, Janus API versions, OS versions, architecture, dependencies, hardware requirements, conflicts, and declared permissions.
- **Trust and Integrity Service:** verifies package hashes and signatures; records publisher identity and trust decisions.
- **Permission Broker:** grants narrowly scoped access to files, network, radios, sensors, USB, Bluetooth, cameras, microphones, and other protected resources.
- **Audit Service:** records installation, update, permission, hardware, and privileged-action events with timestamps and module identity.
- **Aria Capability Interface:** exposes machine-readable descriptions and safe invocation APIs to Aria without granting blanket system access.

The registry is the source of truth for what Janus can currently do. Catalog listings and marketing descriptions are not proof of installed or working capabilities.

## Module manifest

Every installable module must provide a versioned manifest containing:

- Unique module ID and human-readable name.
- Module version and manifest schema version.
- Publisher/maintainer identity and source.
- Description, category, license, and documentation.
- Supported Janus API and OS version ranges.
- Supported CPU architectures and operating environments.
- Dependencies, optional dependencies, conflicts, and required services.
- Hardware IDs, interfaces, firmware, and minimum resource requirements.
- Requested permissions, purpose for each permission, and whether access is optional.
- Package hashes and signature metadata.
- Entry points, declared capabilities, health checks, and uninstall/rollback behavior.
- Support status: planned, experimental, available, unavailable, deprecated, or unsupported.

Manifests must be validated before installation. Unknown or unsupported schema versions must fail safely rather than being guessed.

## Capability lifecycle

1. **Discover:** identify a module package or newly attached hardware using known descriptors and supported interfaces.
2. **Describe:** show what it is, its provenance, requirements, risks, and the capabilities it could provide.
3. **Validate:** check signatures or explicit trust, integrity, compatibility, dependencies, conflicts, and resource requirements.
4. **Authorize:** request only the permissions required for the selected functions. High-impact permissions require a clear explanation and affirmative operator approval.
5. **Install or bind:** install the module or bind a supported driver to the hardware using a controlled process.
6. **Verify:** run declared health checks and confirm real behavior. A successful install is not proof that every advertised capability works.
7. **Register:** publish verified capabilities and their current status in the Capability Registry.
8. **Operate:** enforce permission checks, resource limits, isolation, and audit logging on every invocation.
9. **Update or remove:** preserve user data where appropriate, support rollback, revoke permissions, and unregister capabilities cleanly.

Hardware discovery must be passive by default. It must not transmit, flash firmware, unlock devices, change radio state, or install drivers without appropriate explicit authorization.

## Capability status and support tiers

Each capability must report one of these states:

- **Verified:** implemented and passed relevant automated and hardware validation.
- **Available, not hardware-tested:** software path exists but target physical hardware has not been validated.
- **Experimental:** usable for evaluation with known limitations.
- **Unavailable:** dependency, permission, hardware, driver, or service is missing.
- **Planned:** design intent only; no working implementation.
- **Simulated:** demonstration behavior only; never present as a real operation.
- **Failed:** attempted verification failed.

For Titan and Monolith, additionally identify where the capability runs: Titan-native, Monolith-assisted, external-accessory dependent, remote-service dependent, software-only, or unsupported on this device.

The UI and Aria must show these distinctions. Never return a success result merely because a stub or placeholder was called.

## Security and reliability requirements

- Prefer signed packages from trusted publishers; allow local or community packages only through explicit trust decisions.
- Verify package integrity before installation and after download.
- Use least-privilege permissions and revoke grants when modules are disabled or removed.
- Sandbox untrusted or third-party code where technically feasible; isolate native or privileged modules behind narrow service APIs.
- Apply CPU, memory, storage, network, and execution-time limits where practical.
- Keep core boot, recovery, identity, permission, and update functions independent from optional modules.
- Support safe mode and rollback if an update prevents startup or breaks a critical service.
- Do not silently downgrade security controls to make a module work.
- Record module provenance, version, permissions, and lifecycle events in the audit trail.
- Require explicit confirmation for destructive actions, firmware changes, radio transmission configuration, and other high-impact operations.
- Preserve offline operation for core functions; clearly identify modules that require cloud services.

## Janus Capability Catalog

A future catalog may organize extensions into communications and networking; Wi-Fi, Bluetooth, NFC, UWB, GNSS, Sub-GHz, and SDR; cybersecurity assessment and defensive operations; mobile servicing; reverse engineering and firmware analysis; digital forensics; hardware diagnostics and instrumentation; AI skills and model/provider integrations; and developer tools, automation, and accessibility.

The catalog is a distribution and discovery surface, not the security boundary. Enforcement belongs in the Module Manager, Permission Broker, runtime isolation, and OS services. Listings must show publisher, version, compatibility, permissions, support status, and validation evidence before installation.

## Titan and Monolith relationship

Titan must remain independently useful and retain its onboard capabilities when undocked. Monolith adds compute, storage, thermal capacity, antenna options, and supported radio front ends through a secure, authenticated, high-speed connection.

The Capability Registry must distinguish local Titan capabilities from Monolith-assisted capabilities. On docking, Janus may discover and expose additional verified resources. On undocking or link failure, dependent operations must stop safely or fall back to a verified Titan-native implementation. The system must not imply that Monolith hardware is present when it is not.

## Aria integration

Aria should explain which capabilities are installed, available, experimental, simulated, or unavailable; identify required hardware and permissions; recommend compatible modules with publisher, permissions, and risks; request approval before installation or privileged use; coordinate tools only through documented APIs and granted permissions; report actual output, errors, and uncertainty; and explain dependencies on Titan, Monolith, accessories, internet access, or OS privileges.

Aria is a coordinator and user interface to capabilities, not a permission bypass or unrestricted root process.

## Initial implementation sequence

1. Audit existing Rust crates, Lua runtime, plugin directories, Android app, and manifests. Mark real implementations separately from stubs and demonstrations.
2. Define the versioned module manifest and capability status types in the shared core crate.
3. Implement a read-only Capability Registry with tests and a machine-readable status API.
4. Implement manifest parsing and compatibility validation without executing module code.
5. Add permission declarations and an auditable Permission Broker.
6. Add safe module installation, integrity verification, disable/remove, and rollback.
7. Add hardware discovery adapters for selected, documented Titan/Monolith development hardware.
8. Integrate Aria through read-only capability discovery first, then permissioned invocation.
9. Build the catalog UI only after the underlying registry, trust, permissions, and lifecycle services work.

## Acceptance criteria

- Invalid, incompatible, unsigned, or corrupted packages are rejected according to the configured trust policy.
- Every installed module has a validated manifest and inspectable permission record.
- A module cannot access a protected resource without an explicitly granted capability.
- Disabling or removing a module revokes its access and removes its active capabilities.
- Failed updates can be rolled back without losing unrelated user data.
- Hardware discovery never reports unknown hardware as supported.
- The registry distinguishes planned, experimental, simulated, unavailable, and verified functionality.
- Aria can explain capability status and cannot bypass the Permission Broker.
- Automated tests cover manifest validation, compatibility, permissions, lifecycle, rollback, and failure paths.
- Hardware-dependent claims are backed by tests on the named hardware revision.

## Current implementation status

This document defines the target architecture. It does not assert that the Capability Registry, Marketplace, hardware discovery, package signing, sandboxing, permission broker, or rollback system is already implemented. These must be audited and delivered incrementally with evidence.
