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

The Decimal minimum includes the upstream fix for
[CVE-2026-32686](https://cna.erlef.org/cves/CVE-2026-32686.html).
The advisory feed no longer marks the tested 3.1.1 release as affected, so the
temporary false-positive acknowledgement has been removed. The only remaining
package advisory acknowledgement is the scoped Cloak finding described below.

## Cloak AES-CTR advisory scope

The distribution pins JournalAsh/SolidAsh revisions that enforce AES-256-GCM
for all configured keys, including decryption rotation keys. CTR and legacy CTR
are rejected. EEF-CVE-2026-95105 concerns only the unauthenticated CTR modes;
Hex flags the whole package, so this advisory is explicitly acknowledged while
all other security findings continue to fail audits. See the security policies
and CTR rejection/tampering tests in those libraries. Hosts using Cloak directly
must enforce the same GCM-only policy; existing CTR data requires an explicit
trusted migration before updating. Never treat this acknowledgement as approval
to enable CTR.

## Optional strict host inventory gate

The recovered `mix ash_lotus.security` task checks immutable reviewed Git
sources, native security source hashes, patched version floors, and an explicit
complete host vault inventory before invoking Hex in a separate process. Its
strict contract rejects standing project or environment audit overrides; hosts
using this gate must remove those overrides first. It then supplies only the
reviewed CTR advisory acknowledgement to the child process. This does not change
the parent VM's environment.

The ordinary distribution and consumer checks continue using the narrow project
acknowledgement above. The optional strict task is not implicitly run by those
checks. The review anchors in `AshLotus.Security.Provenance` identify exact source
revisions; an anchor advances only after the owning library's verification.
