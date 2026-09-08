# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.Consumer.ReleaseCheck do
  @moduledoc false

  require Logger

  alias AshLotus.Consumer.Note

  @event "ash_lotus.consumer.release_check"
  @required_applications [:ash, :journal_ash, :solid_ash, :cinder, :ash_lotus]
  @required_modules [Ash, JournalAsh, SolidAsh, Cinder]

  def run! do
    {:ok, _started} = Application.ensure_all_started(:ash_lotus_consumer)

    assert_dependencies_loaded!()
    assert_dependencies_started!()
    assert_ash_round_trip!()
    assert_journal_round_trip!()

    :ok
  end

  defp assert_dependencies_loaded! do
    Enum.each(@required_modules, fn module ->
      unless Code.ensure_loaded?(module), do: raise("missing curated module #{inspect(module)}")
    end)
  end

  defp assert_dependencies_started! do
    started = Application.started_applications() |> Enum.map(&elem(&1, 0)) |> MapSet.new()

    Enum.each(@required_applications, fn application ->
      unless MapSet.member?(started, application) do
        raise "curated application did not start: #{inspect(application)}"
      end
    end)
  end

  defp assert_ash_round_trip! do
    note =
      Note
      |> Ash.Changeset.for_create(:create, %{title: "synthetic release check"})
      |> Ash.create!()

    unless is_binary(note.id) and note.title == "synthetic release check" do
      raise "Ash embedded create action failed"
    end
  end

  defp assert_journal_round_trip! do
    :ok = JournalAsh.Store.Memory.clear()
    Logger.info("synthetic AshLotus release check", event: @event)
    :ok = JournalAsh.flush(5_000)

    case JournalAsh.health() do
      %{
        status: :ready,
        logger: %{
          primary_filter: :installed,
          primary_filter_order: :last,
          primary_filter_default: :log
        }
      } ->
        :ok

      health ->
        raise "JournalAsh is not release-ready: #{inspect(health)}"
    end

    unless Enum.any?(JournalAsh.Store.Memory.entries(), &(&1.event == @event)) do
      raise "Logger observation did not reach the JournalAsh store"
    end
  end
end
