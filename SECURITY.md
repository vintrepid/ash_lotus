<!--
SPDX-FileCopyrightText: 2026 Vince Nibler

SPDX-License-Identifier: MIT
-->

# Security Policy

AshLotus is currently an experimental alpha. Report vulnerabilities through
GitHub private vulnerability reporting; do not publish credentials, customer
data, private logs, or exploit details in a public issue.

The distribution is a software bill of materials. Every first-party Git
dependency must be pinned to an immutable commit, and a pin moves only after
the compatibility and advisory checks pass. Applications must still configure
the security boundaries of the supplied libraries, including authorization,
tenancy, encryption keys, journal retention, and database access.

The final reviewed graph selects Decimal 3.1.2, Spark 2.7.6,
AshAuthenticationPhoenix 2.17.4 and Mint 1.10.2, preserving unrelated locked
versions. The owned authentication fork incorporates the full upstream 4.15.0
maintenance release, including the JTI-session revocation fix for
[CVE-2026-86533](https://cna.erlef.org/cves/CVE-2026-86533.html).
Hex does not audit Git overrides: the manual gate separately verifies exact
immutable repository/lock/fetched revisions, clean runtime source, loaded
version metadata and reviewed SHA-256 security-source anchors. The owning
[authentication attestation](https://github.com/vintrepid/ash_authentication/blob/f0f1eb34e20ce0cdcfd11ef4b07585b3b9e61368/security_attestation.json)
records upstream ancestry, source deviations and native regression checks.

## Manual, inventoried Cloak check

Cloak 1.1.4 remains affected as a package by
[CVE-2026-95105](https://cna.erlef.org/cves/CVE-2026-95105.html); no fixed Cloak
release is available. A raw `mix hex.audit` has no exclusions and still fails
for that package advisory. It must not be described as a clean raw audit.

`mix ash_lotus.security` is a separate, manual, fail-closed check. It requires a
complete host inventory declared in `mix.exs`, for example:

```elixir
ash_lotus: [security: [cloak_inventory: :complete, cloak_vaults: []]]
```

The empty inventory must match discovery of configured/active vaults and
compiled Cloak-vault implementations. If used, the only reviewed ongoing
guarded implementation is `{:solid_ash, SolidAsh.Vault}`. An extra vault cannot
be concealed by declaring only one safe vault. Arbitrary custom vaults,
including presently unconfigured or apparently GCM-only ones, are rejected;
their callbacks and imperative startup options have not been attested.

The pinned native SolidAsh guard checks every cipher, including rotation
decryptors, at startup, caching, hot upgrade and encrypt/decrypt boundaries.
Only authenticated AES-GCM is accepted. Existing CTR ciphertext must be
migrated and verified separately before adopting this guard; this work does
not authorize, perform or supply a fallback for such a migration.

Only after immutable source, patched-version and complete native inventory
checks pass does the task run Hex's real audit in a fresh child process with
exactly `CVE-2026-95105` acknowledged for this reviewed GCM-only boundary. The
acknowledgement is limited to tested Cloak 1.1.4; other releases require review.
It is not a blanket package ignore or certification of un-inventoried hosts.
Existing project/environment ignores are rejected, every other advisory or
retirement retains its native failure, and no acknowledgement is persisted.

The manual task loads application metadata without starting applications,
vaults or workers. Resolved native dependencies explicitly marked `app: false`
are non-OTP assets and do not require an `.app` file. Only that explicit native
option excludes metadata loading: missing real application metadata,
`compile: false` alone, and missing root metadata still fail closed. Native
vault discovery is not disabled by this asset distinction.
It makes no database, ciphertext or provider writes. Its
conditional scope was explicitly approved on 2026-10-11. Standing aliases,
consumer scripts and CI remain unchanged pending separate wiring approval;
they must not be represented as enforcing this manual inventory contract.
