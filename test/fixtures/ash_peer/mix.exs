# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.TestPeer.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_lotus_test_peer,
      version: "0.1.0",
      elixir: "~> 1.20",
      deps: [{:ash, "~> 3.0"}]
    ]
  end

  def application, do: [extra_applications: []]
end
