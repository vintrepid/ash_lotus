# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule Mix.Tasks.AshLotus.Security do
  @shortdoc "Verify reviewed Git sources and conditionally audit the GCM-only distribution"
  @moduledoc """
  Verifies the reviewed immutable dependency provenance and explicit Cloak vault
  inventory before running Hex's native audit in a separate, controlled process.

  Declare the complete host inventory in `mix.exs`:

      ash_lotus: [security: [cloak_inventory: :complete, cloak_vaults: []]]

  If configured, the native guarded vault is listed as `{:solid_ash,
  SolidAsh.Vault}`. Additional arbitrary vaults are not covered. The empty list
  means no configured vault; discovery must confirm that declaration. This task
  starts no vault, worker or application and makes no database or provider writes.

  After validation, precisely `CVE-2026-95105` is acknowledged as inapplicable to
  the reviewed GCM-only boundary. Every other advisory and retirement fails the
  native audit. Existing project/environment audit overrides are rejected. A raw
  `mix hex.audit` continues to report Cloak's package-wide advisory.
  """

  use Mix.Task

  @requirements ["loadpaths"]

  @impl Mix.Task
  def run([]) do
    Mix.Task.run("compile", ["--warnings-as-errors"])

    # Native dependency options distinguish app:false assets from real OTP
    # applications. Missing metadata for actual applications still fails closed.
    versions =
      case AshLotus.Security.load_application_metadata(
             Mix.Dep.cached(),
             Mix.Project.config()[:app]
           ) do
        {:ok, versions} -> versions
        {:error, message} -> Mix.raise(message)
      end

    assert_ok!(AshLotus.Security.validate_hex_floors(versions))
    assert_ok!(AshLotus.Security.validate_advisory_scope(versions))

    assert_ok!(
      AshLotus.Security.verify_provenance(
        Mix.Dep.Lock.read(),
        Mix.Project.deps_paths(),
        AshLotus.Security.Provenance.reviewed()
      )
    )

    policy = get_in(Mix.Project.config(), [:ash_lotus, :security])

    assert_ok!(AshLotus.Security.validate_vault_inventory(policy))

    assert_ok!(
      AshLotus.Security.validate_audit_overrides(
        Mix.Project.config()[:hex] || [],
        System.get_env()
      )
    )

    {output, status} =
      System.cmd(
        System.find_executable("mix") || Mix.raise("mix executable unavailable"),
        ["hex.audit"],
        env: AshLotus.Security.audit_environment(),
        stderr_to_stdout: true
      )

    Mix.shell().info(output)

    assert_ok!(AshLotus.Security.validate_audit_result(status))

    Mix.shell().info(
      "AshLotus security gate passed; the single CTR advisory acknowledgement is scoped to the verified inventory"
    )
  end

  def run(_), do: Mix.raise("ash_lotus.security takes no exemption or bypass options")

  defp assert_ok!(:ok), do: :ok
  defp assert_ok!({:error, message}), do: Mix.raise(message)
end
