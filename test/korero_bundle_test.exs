# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

# Synthetic fixture exercises the pinned native installer, not host authentication.
defmodule AshLotus.KoreroBundleTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "bundle composes the pinned native Korero installer with host-private routing" do
    igniter = install_korero_bundle()

    assert igniter.issues == []
    assert igniter.warnings == []
    assert igniter.assigns.ash_lotus_installers == ["ash", "korero"]
    assert_creates(igniter, "lib/test/workspace/task.ex")
    assert_creates(igniter, "lib/test/workspace/message.ex")
    assert_creates(igniter, "lib/test/workspace/channel.ex")
    assert Enum.map(igniter.tasks, &elem(&1, 0)) == ["ash.codegen"]
    assert_has_task(igniter, "ash.codegen", ["install_korero"])
    assert_unchanged(igniter, "lib/test/application.ex")

    router = Rewrite.source!(igniter.rewrite, "lib/test_web/router.ex")
    content = Rewrite.Source.get(router, :content)
    assert content =~ "TestWeb.LiveAuth, :required"
    assert content =~ ~s("/work")
    assert content =~ "TestWeb.InboxLive"

    task = Rewrite.source!(igniter.rewrite, "lib/test/workspace/task.ex")
    content = Rewrite.Source.get(task, :content)
    assert content =~ "Test.KoreroRepo"
    assert content =~ "Test.Accounts.User"
    assert content =~ "Ash.Policy.Authorizer"
    assert content =~ "relate_actor(:owner)"
  end

  test "bundle Korero composition and applied reruns do not duplicate routes or migrations" do
    first = install_korero_bundle()
    second = Igniter.compose_task(first, "ash_lotus.install", korero_bundle_argv())

    assert second.issues == []
    assert diff(second) == diff(first)
    assert second.tasks == first.tasks

    applied =
      first
      |> apply_igniter!()
      |> Map.put(:tasks, [])
      |> Map.update!(:assigns, &Map.delete(&1, :ash_lotus_installers))
      |> Igniter.compose_task("ash_lotus.install", korero_bundle_argv())

    assert applied.issues == []
    assert applied.warnings == []
    assert_unchanged(applied)
    assert applied.tasks == []
  end

  defp install_korero_bundle do
    test_project(
      files: %{
        ".formatter.exs" => """
        [import_deps: [:ash, :reactor], inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]]
        """,
        "lib/test/accounts/user.ex" => """
        defmodule Test.Accounts.User do
          use Ash.Resource, data_layer: Ash.DataLayer.Ets
          attributes do
            uuid_primary_key :id
          end
        end
        """,
        "lib/test/korero_repo.ex" => """
        defmodule Test.KoreroRepo do
          use AshPostgres.Repo, otp_app: :test
        end
        """,
        "lib/test/application.ex" => """
        defmodule Test.Application do
          use Application
          def start(_type, _args), do: Supervisor.start_link([], strategy: :one_for_one)
        end
        """,
        "lib/test_web/router.ex" => """
        defmodule TestWeb.Router do
          use Phoenix.Router
          import Phoenix.LiveView.Router
          pipeline :browser do
            plug :fetch_session
          end
        end
        """,
        "lib/test_web/inbox_live.ex" => """
        defmodule TestWeb.InboxLive do
          use Phoenix.LiveView
        end
        """,
        "lib/test_web/live_auth.ex" => """
        defmodule TestWeb.LiveAuth do
          def on_mount(:required, _params, _session, socket), do: {:cont, socket}
        end
        """
      }
    )
    |> Igniter.compose_task("ash_lotus.install", korero_bundle_argv())
  end

  defp korero_bundle_argv do
    [
      "--libraries",
      "ash,korero",
      "--korero.domain",
      "Test.Workspace",
      "--korero.user-resource",
      "Test.Accounts.User",
      "--korero.repo",
      "Test.KoreroRepo",
      "--korero.router",
      "TestWeb.Router",
      "--korero.live-view",
      "TestWeb.InboxLive",
      "--korero.on-mount",
      "TestWeb.LiveAuth:required",
      "--korero.path",
      "/work",
      "--yes"
    ]
  end
end
