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

The Decimal range is constrained to `>= 3.0.0 and < 4.0.0`, which includes the
upstream fix for [CVE-2026-32686](https://cna.erlef.org/cves/CVE-2026-32686.html).
The current advisory feed marks every version
affected, so `mix hex.audit` explicitly acknowledges only
`EEF-CVE-2026-32686`; other advisories remain failures.
