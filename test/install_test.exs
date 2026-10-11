# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule AshLotus.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "every selected dependency is accounted for and required installers cannot vanish" do
    plan = AshLotus.Install.plan(AshLotus.Install.libraries(), fn _task -> nil end)

    assert plan.installers == []
    assert plan.required_missing == ["korero"]
    assert plan.without_installer == AshLotus.Install.libraries()
    assert plan.uncomposable == []
  end

  test "ordinary Mix tasks are not mistaken for Igniter installers" do
    plan = AshLotus.Install.plan(["korero"], fn _task -> Mix.Tasks.Compile end)

    assert plan.installers == []
    assert plan.uncomposable == ["korero"]
  end

  test "composes the actual Ash installers in distribution order" do
    igniter = install(["--libraries", "ash_state_machine,ash", "--yes"])

    assert igniter.issues == []
    assert igniter.assigns.ash_lotus_installers == ["ash", "ash_state_machine"]

    assert_creates(igniter, "config/config.exs", fn content ->
      assert content =~ "default_string_length_count: :codepoints"
    end)

    assert_has_patch(igniter, ".formatter.exs", """
      + |  import_deps: [:ash_state_machine, :ash, :reactor]
    """)

    assert igniter.tasks == []
  end

  test "native options are passed through, including disabling optional dependencies" do
    disabled = install(["--libraries", "ash_ai", "--no-req-llm", "--yes"])
    enabled = install(["--libraries", "ash_ai", "--yes"])

    assert disabled.issues == []
    assert enabled.issues == []
    assert_unchanged(disabled, "mix.exs")

    assert_has_patch(enabled, "mix.exs", """
      + |      {:req_llm, "~> 1.18"}
    """)
  end

  test "native repo option is honored and only code generation is scheduled" do
    igniter = install(["--libraries", "ash_postgres", "--repo", "Test.KitchenRepo", "--yes"])

    assert igniter.issues == []
    assert_creates(igniter, "lib/test/kitchen_repo.ex")
    assert Enum.any?(igniter.tasks, &(elem(&1, 0) == "ash.codegen"))

    refute Enum.any?(
             igniter.tasks,
             &(elem(&1, 0) in ["ash.setup", "ash.migrate", "ecto.migrate", "run"])
           )
  end

  test "native namespaced options survive the bundle's own argument parsing" do
    igniter =
      install([
        "--libraries",
        "ash_postgres",
        "--ash-postgres.install.repo",
        "Test.SpecialRepo",
        "--yes"
      ])

    assert igniter.issues == []
    assert_creates(igniter, "lib/test/special_repo.ex")
    refute_creates(igniter, "lib/test/repo.ex")
  end

  test "duplicate composition does not run the same native installer twice" do
    argv = ["--libraries", "ash,ash,ash_ai", "--no-req-llm", "--yes"]
    first = install(argv)
    second = Igniter.compose_task(first, "ash_lotus.install", argv)

    assert second.issues == []
    assert second.assigns.ash_lotus_installers == ["ash", "ash_ai"]
    assert diff(second) == diff(first)
    assert second.tasks == first.tasks
  end

  test "the actual Ash install is idempotent across applied runs" do
    argv = ["--libraries", "ash,ash_state_machine", "--yes"]

    install(argv)
    |> apply_igniter!()
    |> Map.update!(:assigns, &Map.delete(&1, :ash_lotus_installers))
    |> Igniter.compose_task("ash_lotus.install", argv)
    |> assert_unchanged()
  end

  test "repeated namespaced selection flags retain every selected library" do
    igniter =
      install([
        "--ash-lotus.libraries",
        "ash_state_machine",
        "--ash-lotus.libraries",
        "ash_ai",
        "--no-req-llm",
        "--yes"
      ])

    assert igniter.issues == []
    assert igniter.assigns.ash_lotus_installers == ["ash_state_machine", "ash_ai"]
  end

  test "a selected dependency with no installer is explicitly reported" do
    install(["--libraries", "decimal", "--yes"])
    |> assert_has_notice(
      &String.contains?(
        &1,
        "Libraries without a native installer: decimal. These were not installed"
      )
    )
    |> assert_unchanged()
  end

  test "unknown libraries fail before any native installer modifies files" do
    install(["--libraries", "ash,not_curated", "--yes"])
    |> assert_has_issue(&String.contains?(&1, "Unknown curated libraries: not_curated"))
    |> assert_unchanged()
  end

  test "database setup options are rejected before modifying the host" do
    for setup <- ["--setup", "--ash.install.setup"] do
      install(["--libraries", "ash", setup, "--yes"])
      |> assert_has_issue(&String.contains?(&1, "does not run database setup"))
      |> assert_unchanged()
    end
  end

  defp install(argv) do
    test_project()
    |> Igniter.compose_task("ash_lotus.install", argv)
  end
end
