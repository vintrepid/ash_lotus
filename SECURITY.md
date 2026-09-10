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
