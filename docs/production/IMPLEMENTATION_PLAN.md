# Janus Production Implementation Plan

Janus is being developed as an authorized-services product. A paid license enables
product features; it never replaces a customer's written authorization or engagement scope.

## Enforced execution decision

A real backend operation may execute only if all checks succeed:

1. operator is authenticated and authorized for the organization;
2. signed license is valid and includes the requested feature;
3. engagement is active and belongs to the licensed organization;
4. feature, target asset, and/or evidence location are in the engagement scope;
5. the module has a vetted backend implementation; and
6. an audit event is recorded before and after execution.

Unsupported modules must be reported as **unavailable**. They must not emit simulated
success output in production mode.

## Hybrid licensing

- The licensing service signs `LicenseClaims` with an Ed25519 private key.
- Customer appliances contain only the matching public key.
- Online deployments may refresh/revoke licenses with the licensing service.
- Enterprise/offline deployments validate a time-bounded signed license file locally.
- License signing keys are never committed to source control, installed on customer devices,
  or exposed to browser code.

## Delivery order

1. Identity, organizations, and roles.
2. License storage, online refresh/revocation, and offline signed-license validation.
3. Engagement persistence, scoped-target parsing, authorization-document metadata, and approval workflow.
4. Append-only audit and evidence hashing/export.
5. Read-only forensics services and authorized network diagnostics.
6. Explicit adapters for supported customer-owned serial/USB hardware.
7. A web dashboard driven by real runtime API responses, not the demo Lua runner.

## Module certification registry

Every module receives a deterministic module ID and SHA-256 content hash from the
inventory. The runtime will later look up that exact ID/hash pair in the
`module_certifications` table before any production execution. A changed Lua file
invalidates prior certification until it is reviewed again.

## Execution gate

`authorize_execution` is the mandatory policy decision point for production
handlers. It validates the signed license, organization relationship, module
certification status, content hash, licensed feature, engagement time window,
and exact approved target before a handler is allowed to run.
