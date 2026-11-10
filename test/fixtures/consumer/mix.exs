# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.Consumer.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_lotus_consumer,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: [
        {:ash_lotus, path: "../../.."},
        {:ash_lotus_test_peer, path: "../ash_peer"},
        # Mix overrides apply above a dependency, not across sibling branches.
        # Keep this aligned with the core pin governed by AshLotus.
        {:ash,
         github: "vintrepid/ash_lotus_core",
         ref: "da6f68c184eb45888961cae74b8c8837a789b0d3",
         override: true}
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end
end
