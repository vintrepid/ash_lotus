# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.AshLotus.Install do
    @shortdoc "Run the curated dependencies' native installers"
    @moduledoc """
    Installs the AshLotus distribution into a host using each library's public
    installer. Run `mix ash_lotus.install` after adding AshLotus and Igniter.
    Nested installer options are passed through.

    By default every curated library's native installer is composed. For an
    existing host, `--libraries ash,korero` explicitly selects a subset. Native
    flags such as `--repo`, `--user`, and `--no-req-llm` are passed through; use
    Igniter's namespaced flags when native option names conflict.

    Libraries without installers remain dependencies; they are reported explicitly.
    Korero's installer is required when Korero is selected. Ordinary Mix installers
    which cannot be composed are errors, not successful no-ops.
    Configuration requiring credentials or host policy stays with the host. This
    task does not migrate a database, start workers, or send messages. `--setup`
    is deliberately rejected. Native installers may schedule Ash code generation
    and configure host supervision for a later application start.
    """
    use Igniter.Mix.Task

    @impl true
    def info(argv, _parent) do
      plan = AshLotus.Install.plan(selected_libraries(argv))

      %Igniter.Mix.Task.Info{
        group: :ash_lotus,
        schema: [libraries: :csv],
        composes: Enum.map(plan.installers, &(&1 <> ".install"))
      }
    end

    @impl true
    def igniter(igniter) do
      plan = AshLotus.Install.plan(selected_libraries(igniter.args.argv))

      issues =
        []
        |> issue_if(
          plan.unknown != [],
          "Unknown curated libraries: #{Enum.join(plan.unknown, ", ")}."
        )
        |> issue_if(
          plan.required_missing != [],
          "Required native installers are missing: #{Enum.join(plan.required_missing, ", ")}. " <>
            "Install an AshLotus revision whose pinned dependencies provide them."
        )
        |> issue_if(
          plan.uncomposable != [],
          "Native installers cannot be composed: #{Enum.join(plan.uncomposable, ", ")}. " <>
            "Recompile these dependencies with Igniter available; no ordinary Mix task was silently skipped."
        )
        |> issue_if(
          setup_requested?(igniter.args.argv),
          "ash_lotus.install does not run database setup. Run the host's setup workflow separately after reviewing generated changes."
        )

      if issues == [] do
        compose_installers(igniter, plan)
      else
        Enum.reduce(issues, igniter, &Igniter.add_issue(&2, &1))
      end
    end

    defp compose_installers(igniter, plan) do
      composed = igniter.assigns[:ash_lotus_installers] || []
      previous_task_count = length(igniter.tasks)

      igniter =
        Enum.reduce(plan.installers -- composed, igniter, fn library, acc ->
          acc
          |> Igniter.compose_task(library <> ".install", igniter.args.argv)
          |> Igniter.assign(
            :ash_lotus_installers,
            Enum.uniq((acc.assigns[:ash_lotus_installers] || []) ++ [library])
          )
        end)

      igniter =
        if plan.without_installer == [] do
          igniter
        else
          Igniter.add_notice(
            igniter,
            "Libraries without a native installer: #{Enum.join(plan.without_installer, ", ")}. " <>
              "These were not installed; their configuration remains host-owned."
          )
        end

      newly_scheduled = Enum.drop(igniter.tasks, previous_task_count)

      if Enum.any?(
           newly_scheduled,
           &(elem(&1, 0) in ["ash.setup", "ash.migrate", "ecto.create", "ecto.migrate", "run"])
         ) do
        Igniter.add_issue(
          igniter,
          "A native installer scheduled runtime or database setup. Review it separately; AshLotus will not apply this installation."
        )
      else
        igniter
      end
    end

    defp selected_libraries(argv) do
      argv = Igniter.Util.Info.args_for_group(argv, "ash-lotus")
      {options, _rest, _invalid} = OptionParser.parse(argv, switches: [libraries: :keep])

      case Keyword.get_values(options, :libraries) do
        [] -> AshLotus.Install.libraries()
        libraries -> Enum.flat_map(libraries, &String.split(&1, ",", trim: true))
      end
    end

    defp setup_requested?(argv) do
      argv = Igniter.Util.Info.args_for_group(argv, "ash.install")
      {options, _rest, _invalid} = OptionParser.parse(argv, switches: [setup: :boolean])
      options[:setup] == true
    end

    defp issue_if(issues, true, issue), do: issues ++ [issue]
    defp issue_if(issues, false, _issue), do: issues
  end
else
  defmodule Mix.Tasks.AshLotus.Install do
    use Mix.Task
    @shortdoc "Run the curated dependencies' native installers (requires Igniter)"
    @impl true
    def run(_argv) do
      Mix.raise(
        "ash_lotus.install requires Igniter. Add {:igniter, \"~> 0.8\"} to the host dependencies."
      )
    end
  end
end
