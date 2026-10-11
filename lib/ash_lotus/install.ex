# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule AshLotus.Install do
  @moduledoc """
  Installation accounting for the curated distribution.

  An installer must implement the Igniter composition contract, not merely have
  a Mix task with an `.install` suffix. Igniter silently ignores ordinary Mix
  tasks when composing; treating those tasks as installed would be misleading.
  """

  @libraries ~w(ash ash_postgres ash_phoenix ash_state_machine ash_oban ash_money ash_admin ash_authentication ash_authentication_phoenix ash_json_api ash_ai ash_cloak ash_paper_trail ash_archival ash_sql ex_money_sql decimal cinder journal_ash solid_ash tag_ash korero)

  @doc "The libraries whose public installers are composed in dependency order."
  def libraries, do: @libraries

  @required_installers ["korero"]

  @doc "Find composable installers and explicitly account for every selected library."
  def plan(libraries \\ @libraries, resolver \\ &Mix.Task.get/1) do
    unknown = Enum.reject(libraries, &(&1 in @libraries))

    plan =
      @libraries
      |> Enum.filter(&(&1 in libraries))
      |> Enum.reduce(%{installers: [], without_installer: [], uncomposable: []}, fn library,
                                                                                    acc ->
        task = resolver.(library <> ".install")

        kind =
          cond do
            is_nil(task) -> :without_installer
            composable?(task) -> :installers
            true -> :uncomposable
          end

        Map.update!(acc, kind, &(&1 ++ [library]))
      end)

    plan
    |> Map.put(:unknown, Enum.uniq(unknown))
    |> Map.put(
      :required_missing,
      Enum.filter(plan.without_installer, &(&1 in @required_installers))
    )
  end

  defp composable?(task) when is_atom(task) do
    Code.ensure_loaded?(task) && function_exported?(task, :run, 1) &&
      (function_exported?(task, :igniter, 1) || function_exported?(task, :igniter, 2))
  end

  defp composable?(_task), do: false
end
