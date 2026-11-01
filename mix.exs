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
      description: "The curated Ash distribution for Lotus applications",
      # JournalAsh/SolidAsh enforce GCM for every encryption/rotation key.
      # Hex labels the entire Cloak package; see SECURITY.md.
      hex: [ignore_advisories: ["EEF-CVE-2026-95105"]],
      package: package(),
      docs: docs(),
      source_url: @source_url,
      maestro: [
        owned_branch: "main",
        owned_forks: [
          ash_ri: [
            branch: "main",
            repository: "https://github.com/vintrepid/ash_ri.git",
            update: :manual
          ],
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ash_ri,
       github: "vintrepid/ash_ri", ref: "de13c28039041972c8c03597611708ae4e07e4e0", override: true},
      # Match the Apple identity verification fix already used by consumers.
      {:assent, "~> 0.3.2", override: true},
      {:ash,
       github: "vintrepid/ash_lotus_core",
       ref: "4b4c6fded982d64eab689f0c09d6b60efcbcc9d0",
       override: true},
      {:korero,
       github: "vintrepid/korero", ref: "5b39f59cc4c2693573cae9d80ec90b4f2b1d8351", override: true},
      {:journal_ash,
       github: "vintrepid/journal_ash",
       ref: "898f427b4bb7126fdc3d8d8ca212aefb24e170db",
       override: true},
      {:solid_ash,
       github: "vintrepid/solid_ash",
       ref: "2b2c403d54d9bf09296d70f7d4ed9f2239f19582",
       override: true},
      {:tag_ash,
       github: "vintrepid/tag_ash",
       ref: "2e4a3c71c27b9db1778cd536afc801d13940227f",
       override: true},
      {:cinder, github: "vintrepid/cinder", ref: "9d1140c", override: true},
      {:ash_authentication,
       git: "https://github.com/vintrepid/ash_authentication.git",
       ref: "c28f9396cea7835f0ef3b92ceee303770075bde7",
       override: true},
      {:ash_postgres, "~> 2.15 and >= 2.15.2"},
      {:ash_cloak, "~> 0.5.0"},
      {:ash_phoenix, "~> 2.3 and >= 2.3.26"},
      {:ash_ai, "~> 1.4 and >= 1.4.1"},
      {:ash_paper_trail, "~> 0.8.1"},
      {:ash_state_machine, "~> 0.3.0"},
      {:ash_archival, "~> 2.0 and >= 2.0.5"},
      {:ash_money, "~> 0.2.7"},
      {:ash_oban, "~> 0.10.3"},
      {:ash_admin, "~> 1.4"},
      {:ash_authentication_phoenix, "~> 2.17 and >= 2.17.4"},
      {:ash_json_api, "~> 1.8"},
      {:ash_sql, "~> 0.8.4"},
      {:ex_money_sql, "~> 2.2"},
      {:decimal, "~> 3.2"},
      {:ex_doc, "~> 0.40.4", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_environment), do: ["lib"]

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
