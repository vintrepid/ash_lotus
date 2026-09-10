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

The distribution pins first-party forks by immutable commit. Governed Hex
integrations declare the tested minimum in `mix.exs`, allowing later compatible
versions; `mix.lock` records the exact tested resolution. Stable packages allow
minor and patch updates within their major version. Pre-1.0 packages allow patch
updates within their minor version. Dependency updates must leave the new
minimums visible in the diff, not only replace the lockfile.

Fork policies in `mix.exs` identify each owned branch and its upstream branch.
Update tooling must compare both: being current with our fork does not mean the
fork has incorporated upstream changes. Authentication deliberately tracks
upstream `stable-4.0`, not the next major prerelease on `main`. Git revisions are
advanced only to explicitly reviewed commits; discovery never merges or pushes
forks automatically.

```elixir
defp deps do
  [
    {:ash_lotus,
     github: "vintrepid/ash_lotus",
     tag: "v0.1.0-alpha.2"}
  ]
end
```

### Independent dependencies that also require Ash

The one-dependency example works for a minimal host. If another direct host
dependency declares Hex `:ash`, its declaration is a sibling of AshLotus's Git
core declaration. Mix applies overrides only from an upper dependency level,
not between siblings; moving AshLotus earlier in the list does not fix that
conflict. Such hosts need one explicit top-level exception alongside AshLotus:

```elixir
{:ash,
 github: "vintrepid/ash_lotus_core",
 ref: "88c3fb4243de5c166ca1a71191bf10f5222813d1",
 override: true}
```

Keep this override aligned with the core pin in the installed AshLotus release.
AshLotus still governs that pin and all other curated versions; the host does
not maintain an independent dependency selection. This is a Mix graph constraint,
not a second application API. See Mix's [dependency options](https://hexdocs.pm/mix/Mix.Tasks.Deps.html#module-dependency-definition-options)
and [convergence implementation](https://github.com/elixir-lang/elixir/blob/v1.20.3/lib/mix/lib/mix/dep/converger.ex#L235-L269).

## Curated libraries

The distribution supplies:

- the upstream-tracking `ash_lotus_core` fork as OTP application `:ash`;
- Kōrero for conversations and their work, with Oban-backed execution and an Ash task-queue lifecycle,
  composed into host-owned resources without duplicating their business actions;
- JournalAsh for centrally governed Logger observations and an explicit future
  boundary for transaction-linked committed facts;
- the foundation-stage SolidAsh resources, authorization primitives, and
  encrypted-at-rest pod payload support;
- the maintained Cinder fork for Ash-aware LiveView tables;
- the compatible AshPostgres, AshCloak, AshPhoenix, AI, state-machine, archival,
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
declares a path dependency on `ash_lotus`, a synthetic independent library with
a normal Hex Ash requirement, and the aligned top-level Ash override described
above. It resolves that real dependency graph and exercises native embedded Ash
create actions through both the host and its peer, a Logger-to-JournalAsh retained
observation and health check, a host-owned Korero create/start/complete lifecycle,
and SolidAsh/Cinder module availability. It then assembles an OTP release and
repeats those checks using the release executable. Removing the necessary
override makes this peer graph fail dependency resolution.

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
