<!--
SPDX-FileCopyrightText: 2026 Vince Nibler

SPDX-License-Identifier: MIT
-->

# AshLotus

AshLotus is the thin, curated Ash distribution used by Lotus applications. The
name is deliberate: Ash remains the primary platform and Lotus supplies a small
set of dependency and compatibility decisions. It gives a host application one
dependency contract while preserving the native APIs and independent ownership
of every library in the stack.

The distribution pins the first-party forks by immutable commit and the
governed Ash integrations by exact tested version. Updating those pins is a
compatibility release, not an incidental dependency resolution.

```elixir
defp deps do
  [
    {:ash_lotus,
     github: "vintrepid/ash_lotus",
     tag: "v0.1.0-alpha.2"}
  ]
end
```

The distribution supplies:

- the upstream-tracking `ash_lotus_core` fork as OTP application `:ash`;
- Kōrero for conversations and their work, with Oban-backed execution and an Ash task-queue lifecycle,
  composed into host-owned resources without duplicating their business actions;
- JournalAsh for centrally governed Logger observations and an explicit future
  boundary for transaction-linked committed facts;
- the foundation-stage SolidAsh resources, authorization primitives, and
  encrypted-at-rest pod payload support;
- the maintained Cinder fork for Ash-aware LiveView tables;
- the exact AshPostgres, AshCloak, AshPhoenix, AI, state-machine, archival,
  paper-trail, Oban, admin, authentication, JSON:API, SQL, and money integration
  versions selected for the Lotus stack, including its Ecto money adapter.

Application code still calls `Ash`, `Korero`, `Logger`, `JournalAsh`, `SolidAsh`, and
`Cinder` directly. AshLotus is dependency policy, not a facade.

Korero owns the Oban integration; JournalAsh owns Cloak-backed journal encryption.
Their native `Oban` and `Cloak` APIs are also part of the supplied dependency
contract. Hosts still configure their existing Oban instance and runtime vaults;
adding a dependency does not itself start a job queue or encrypt existing logs.

These are runtime dependencies. Starting `:ash_lotus` starts their OTP
applications; in particular, JournalAsh installs its global Logger primary
filter unless the host explicitly disables that integration. Adoption therefore
requires a release-start and logging smoke test, not only successful compilation.

The companion names express the opposite ownership direction where appropriate:
`solid_ash` is a Solid data system implemented on Ash, and `journal_ash` is a
journal system integrated with Ash. Neither is an Ash subsystem renamed merely
for grouping.

## Why it is separate from the core fork

Korero, JournalAsh, SolidAsh, and Cinder depend on `:ash`. If the `:ash` core project
also depended on those extensions, Mix would have a dependency cycle. The
separate `:ash_lotus` application sits above both core and extensions:

```text
application -> ash_lotus -> :ash
                         -> korero      -> :ash + ash_state_machine + ash_oban + oban
                         -> journal_ash -> :ash + cloak
                         -> solid_ash   -> :ash
                                        -> journal_ash
                                        -> ash_authentication -> :ash
                         -> cinder      -> :ash
```

This keeps the core fork easy to synchronize with `ash-project/ash`, gives
applications a genuinely small `mix.exs`, and leaves an honest acyclic OTP
application graph.

## Status

`0.1.0-alpha.2` is an experimental Git distribution, not a production-readiness
claim for every included integration. All first-party Git dependencies are
pinned to immutable commits for reproducibility, not as a promise of a stable
interface. Pre-1.0 APIs and dependency choices may change between releases.

The initial distribution is installed from Git. Hex packages cannot contain
production Git dependencies, so a Hex release requires publishing the owned
forks as Hex packages first; CI deliberately validates the Git distribution
instead of pretending the current graph is Hex-publishable.

See [SECURITY.md](SECURITY.md) for the dependency-pin and vulnerability
reporting policy.

## Consumer compatibility check

Run `sh scripts/check_consumer.sh` from this checkout. The standalone fixture
declares only a path dependency on `ash_lotus`; it exercises a direct embedded
Ash create action, a Logger-to-JournalAsh retained observation and health check,
a Korero create/start/complete lifecycle through a host-owned Ash resource,
and SolidAsh/Cinder module availability. It then assembles an OTP release and
repeats those checks using the release executable.

Hosts must set Ash's string-counting policy and register SolidAsh's bundled
domain in their own configuration:

```elixir
config :ash, default_string_length_count: :codepoints
config :solid_ash, ash_domains: [SolidAsh.Domain]
```

The fixture uses JournalAsh's bounded, volatile memory store and requires no
database or encryption keys. It does not test durable journal storage, Solid
protocol interoperability, or application-specific authorization and encryption
configuration.
