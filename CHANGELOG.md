<!--
SPDX-FileCopyrightText: 2026 Vince Nibler

SPDX-License-Identifier: MIT
-->

# Changelog

## 0.1.0-alpha.1 - 2026-09-07

- Establish the acyclic AshLotus distribution contract.
- Pin the AshLotus core fork, JournalAsh, SolidAsh, and the maintained Cinder
  fork as one compatible application stack.
- Govern the Ash-family dependency set selected for Lotus applications.
- Verify a standalone consumer declaring only `ash_lotus`, including native
  Ash actions, Logger-to-JournalAsh observations, and an assembled OTP release.
- Enforce reproducible lockfiles and dependency advisory checks in CI.
