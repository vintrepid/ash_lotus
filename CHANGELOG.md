<!--
SPDX-FileCopyrightText: 2026 Vince Nibler

SPDX-License-Identifier: MIT
-->

# Changelog

## 0.1.0-alpha.2 - 2026-09-08

- Supply Korero, the conversation/workflow foundation with an Ash task lifecycle
  and native Oban execution integration, through the curated dependency set.
- Include JournalAsh's explicit Cloak-backed sealed-entry format; default log
  output and the volatile plaintext memory store remain unchanged.
- Verify a host-owned Korero task lifecycle in the standalone consumer and
  assembled release, alongside existing Ash and Logger checks.

## 0.1.0-alpha.1 - 2026-09-07

- Establish the acyclic AshLotus distribution contract.
- Pin the AshLotus core fork, JournalAsh, SolidAsh, and the maintained Cinder
  fork as one compatible application stack.
- Govern the Ash-family dependency set selected for Lotus applications.
- Verify a standalone consumer declaring only `ash_lotus`, including native
  Ash actions, Logger-to-JournalAsh observations, and an assembled OTP release.
- Enforce reproducible lockfiles and dependency advisory checks in CI.
