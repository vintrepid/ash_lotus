# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.MixProject do
  use Mix.Project

  @version "0.1.0-alpha.2"
  @source_url "https://github.com/vintrepid/ash_lotus"

  def project do
    [
      app: :ash_lotus,
      version: @version,
      elixir: "~> 1.20",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_load_filters: [~r{^test/(?!fixtures/).*_test\.exs$}],
      test_ignore_filters: [~r{^test/fixtures/}],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: "The curated Ash distribution for Lotus applications",
      package: package(),
      docs: docs(),
      source_url: @source_url,
      maestro: [
        owned_branch: "main",
        owned_forks: [
          ash: [
            branch: "main",
            repository: "https://github.com/vintrepid/ash_lotus_core.git",
            update: :manual,
            upstream_branch: "main",
            upstream_url: "https://github.com/ash-project/ash.git"
          ],
          ash_authentication: [
            branch: "security/magic-link-hardening-v4",
            repository: "https://github.com/vintrepid/ash_authentication.git",
            update: :manual,
            upstream_branch: "stable-4.0",
            upstream_url: "https://github.com/team-alembic/ash_authentication.git"
          ],
          cinder: [
            branch: "main",
            repository: "https://github.com/vintrepid/cinder.git",
            update: :manual,
            upstream_branch: "main",
            upstream_url: "https://github.com/sevenseacat/cinder.git"
          ],
          journal_ash: [
            branch: "main",
            repository: "https://github.com/vintrepid/journal_ash.git",
            update: :manual
          ],
          korero: [
            branch: "main",
            repository: "https://github.com/vintrepid/korero.git",
            update: :manual
          ],
          solid_ash: [
            branch: "master",
            repository: "https://github.com/vintrepid/solid_ash.git",
            update: :manual
          ],
          tag_ash: [
            branch: "main",
            repository: "https://github.com/vintrepid/tag_ash.git",
            update: :manual
          ]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [preferred_envs: [precommit: :test]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:igniter, "~> 0.8.4", optional: true},
      {:ash,
       github: "vintrepid/ash_lotus_core",
       ref: "070f3e382070699b48f7e823ba004022a7b69d2b",
       override: true},
      {:korero,
       github: "vintrepid/korero", ref: "77ea12fc6dad5970070dde087e03940ed8c7c57d", override: true},
      {:journal_ash,
       github: "vintrepid/journal_ash",
       ref: "898f427b4bb7126fdc3d8d8ca212aefb24e170db",
       override: true},
      {:solid_ash,
       github: "vintrepid/solid_ash",
       ref: "2e3ec1397fc0eef985fb9bff6a5a134ee453a13c",
       override: true},
      {:tag_ash,
       github: "vintrepid/tag_ash",
       ref: "a525fc456e4b0828f08fc61c956c439378ccc2aa",
       override: true},
      {:cinder, github: "vintrepid/cinder", ref: "9d1140c", override: true},
      {:ash_authentication,
       git: "https://github.com/vintrepid/ash_authentication.git",
       ref: "f0f1eb34e20ce0cdcfd11ef4b07585b3b9e61368",
       override: true},
      {:ash_postgres, "~> 2.13 and >= 2.13.1"},
      {:ash_cloak, "~> 0.4.0"},
      {:ash_phoenix, "~> 2.3 and >= 2.3.25"},
      {:ash_ai, "~> 1.0 and >= 1.0.3"},
      {:ash_paper_trail, "~> 0.7.0"},
      {:ash_state_machine, "~> 0.2.13"},
      {:ash_archival, "~> 2.0 and >= 2.0.3"},
      {:ash_money, "~> 0.2.6"},
      {:ash_oban, "~> 0.8.14"},
      {:ash_admin, "~> 1.3 and >= 1.3.2"},
      {:ash_authentication_phoenix, "~> 2.17 and >= 2.17.4"},
      {:ash_json_api, "~> 1.7 and >= 1.7.1"},
      {:ash_sql, "~> 0.7.3"},
      {:ex_money_sql, "~> 2.1 and >= 2.1.0"},
      {:decimal, "~> 3.1 and >= 3.1.2"},
      {:spark, "~> 2.7 and >= 2.7.6"},
      {:mint, "~> 1.10 and >= 1.10.2"},
      {:ex_doc, "~> 0.40.4", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_environment), do: ["lib"]

  defp aliases do
    [
      precommit: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test",
        "cmd sh scripts/check_consumer.sh"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Vince Nibler"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md SECURITY.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "SECURITY.md"]
    ]
  end
end
