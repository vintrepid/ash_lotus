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
temporary false-positive acknowledgement has been removed. `mix hex.audit`
has no advisory exclusions in this distribution.

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
