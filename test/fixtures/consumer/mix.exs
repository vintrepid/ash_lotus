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
      deps: [{:ash_lotus, path: "../../.."}]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end
end
