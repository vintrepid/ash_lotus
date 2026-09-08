<!--
SPDX-FileCopyrightText: 2026 Vince Nibler

SPDX-License-Identifier: MIT
-->

# AshLotus Agent Rules

1. `ash_lotus` is the thin, public distribution above the upstream-tracking
   `ash_lotus_core` fork. It must not copy Ash, JournalAsh, SolidAsh, or Cinder
   application code.
2. Names express the primary abstraction first: Ash is primary in `ash_lotus`;
   Solid and Journal are primary in `solid_ash` and `journal_ash`. Do not rename
   those libraries merely to make the dependency set look uniform.
3. The core fork remains the OTP application `:ash` with the `Ash.*`
   namespace. `ash_lotus` is a separate OTP application whose job is to own a
   tested, compatible dependency set and its installation contract.
4. Preserve an acyclic graph: `ash_lotus` may depend on `:ash` and Ash
   extensions; `:ash` must never depend back on `ash_lotus` or an extension.
5. First-party Git dependencies must use immutable commit refs before a
   release. Moving branches are allowed only while a dependency has no commit.
   Do not claim Hex publishability while production Git dependencies remain.
6. A consumer declaring only `ash_lotus` must be able to compile code using
   the distributed libraries and assemble an OTP release. Keep an integration
   fixture that proves this contract.
7. Keep this project policy-only. App-specific configuration, resources,
   migrations, and business workflows belong in the host application; reusable
   installers belong with the library that owns them.
8. Never commit credentials, production logs, customer data, messages,
   documents, or private operational material. Examples and fixtures must be
   synthetic.
9. Prefer model, dependency-graph, installer, and release tests. Browser tests
   do not belong in this package.
