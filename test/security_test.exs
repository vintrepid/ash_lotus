# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule AshLotus.SecurityTest do
  use ExUnit.Case, async: false

  alias AshLotus.Security

  setup do
    previous = Application.fetch_env(:solid_ash, SolidAsh.Vault)
    Application.delete_env(:solid_ash, SolidAsh.Vault)
    on_exit(fn -> restore_env(:solid_ash, SolidAsh.Vault, previous) end)
    :ok
  end

  test "an unacknowledged or missing complete vault inventory fails closed" do
    assert {:error, _} = Security.validate_vault_inventory(nil)
    assert {:error, _} = Security.validate_vault_inventory([])
    assert {:error, _} = Security.validate_vault_inventory(cloak_vaults: [])
  end

  test "an explicitly complete empty inventory proves only no configured vault" do
    assert :ok = Security.validate_vault_inventory(policy())
  end

  test "declaring one vault cannot conceal another discovered vault" do
    Application.put_env(:solid_ash, SolidAsh.Vault, safe_config())

    with_extra_vault(unsafe_config(), fn ->
      assert {:error, _} =
               Security.validate_vault_inventory(policy([{:solid_ash, SolidAsh.Vault}]))
    end)
  end

  test "an arbitrary custom vault is not trusted merely because its current config is GCM" do
    with_extra_vault(safe_config(), fn ->
      assert {:error, _} =
               Security.validate_vault_inventory(policy([{:ash_lotus, __MODULE__.ExtraVault}]))
    end)
  end

  test "a compiled custom vault cannot hide imperative startup configuration" do
    with_extra_vault(nil, fn ->
      assert {:error, _} = Security.validate_vault_inventory(policy())
    end)
  end

  test "the native guarded SolidAsh vault permits authenticated configuration only" do
    declared = policy([{:solid_ash, SolidAsh.Vault}])
    Application.put_env(:solid_ash, SolidAsh.Vault, safe_config())
    assert :ok = Security.validate_vault_inventory(declared)

    Application.put_env(:solid_ash, SolidAsh.Vault, unsafe_config())
    assert {:error, _} = Security.validate_vault_inventory(declared)

    Application.put_env(
      :solid_ash,
      SolidAsh.Vault,
      Keyword.update!(safe_config(), :ciphers, &(&1 ++ unsafe_config()[:ciphers]))
    )

    assert {:error, _} = Security.validate_vault_inventory(declared)
  end

  test "malformed and duplicate inventories are not accepted" do
    for vaults <- [
          nil,
          [SolidAsh.Vault],
          [{:solid_ash, SolidAsh.Vault}, {:solid_ash, SolidAsh.Vault}]
        ] do
      assert {:error, _} = Security.validate_vault_inventory(policy(vaults))
    end

    assert {:error, _} =
             Security.validate_vault_inventory(
               cloak_inventory: :complete,
               cloak_inventory: :incomplete,
               cloak_vaults: []
             )
  end

  test "preexisting audit overrides cannot widen the conditional acknowledgement" do
    assert :ok = Security.validate_audit_overrides([], %{})
    assert {:error, _} = Security.validate_audit_overrides([ignore_advisories: ["ANY"]], %{})
    assert {:error, _} = Security.validate_audit_overrides([ignore_retirements: [:cloak]], %{})

    assert {:error, _} =
             Security.validate_audit_overrides(
               [ignore_advisories: [], ignore_advisories: ["ANY"]],
               %{}
             )

    assert {:error, _} =
             Security.validate_audit_overrides([], %{"HEX_IGNORE_ADVISORIES" => "ANY"})

    assert {:error, _} =
             Security.validate_audit_overrides([], %{"HEX_IGNORE_RETIREMENTS" => "cloak"})
  end

  test "the controlled audit environment acknowledges precisely one reviewed CVE" do
    assert Security.audit_environment() == [
             {"HEX_IGNORE_ADVISORIES", "CVE-2026-95105"},
             {"HEX_IGNORE_RETIREMENTS", nil}
           ]
  end

  test "the native task offers no command-line exemption or inventory bypass" do
    assert_raise Mix.Error, "ash_lotus.security takes no exemption or bypass options", fn ->
      Mix.Tasks.AshLotus.Security.run(["--ignore-advisory", "UNREVIEWED"])
    end
  end

  test "the source gate rejects a previous or absent Git review anchor" do
    reviewed = AshLotus.Security.Provenance.reviewed()
    assert {:error, _} = Security.verify_provenance(%{}, %{}, reviewed)

    old_lock = %{
      ash_authentication:
        {:git, "https://github.com/vintrepid/ash_authentication.git",
         "42d1af7c9d2078e193b566b75467aa1e3f9acf43", [ref: "42d1af7"]}
    }

    assert {:error, _} = Security.verify_provenance(old_lock, %{}, reviewed)
  end

  test "unrelated advisories and retirement failures retain their native audit failure" do
    assert :ok = Security.validate_audit_result(0)
    assert {:error, _} = Security.validate_audit_result(1)
    assert {:error, _} = Security.validate_audit_result(2)
  end

  test "a later unreviewed Cloak release does not inherit this scoped acknowledgement" do
    assert :ok = Security.validate_advisory_scope(%{cloak: "1.1.4"})
    assert {:error, _} = Security.validate_advisory_scope(%{cloak: "1.1.5"})
    assert {:error, _} = Security.validate_advisory_scope(%{})
  end

  test "patched minimums cannot be bypassed by old or absent package metadata" do
    patched = %{
      decimal: "3.1.2",
      spark: "2.7.6",
      ash_authentication_phoenix: "2.17.4",
      mint: "1.10.2"
    }

    assert :ok = Security.validate_hex_floors(patched)
    assert {:error, _} = Security.validate_hex_floors(%{})

    for {app, old} <- [
          decimal: "3.1.1",
          spark: "2.7.2",
          ash_authentication_phoenix: "2.17.3",
          mint: "1.10.0"
        ] do
      assert {:error, _} = Security.validate_hex_floors(Map.put(patched, app, old))
    end
  end

  @tag tmp_dir: true
  test "native Git provenance rejects changed, ignored and mismatched source", %{
    tmp_dir: directory
  } do
    File.mkdir!(Path.join(directory, "lib"))
    source = "synthetic reviewed native source"
    File.write!(Path.join(directory, "lib/guard.ex"), source)
    File.write!(Path.join(directory, "mix.exs"), "synthetic package metadata")
    File.write!(Path.join(directory, ".gitignore"), "lib/hidden.ex\n")
    git!(directory, ["init", "--quiet"])
    git!(directory, ["add", ".gitignore", "lib/guard.ex", "mix.exs"])

    git!(directory, [
      "-c",
      "user.name=Synthetic fixture",
      "-c",
      "user.email=fixture@example.invalid",
      "commit",
      "--quiet",
      "-m",
      "synthetic reviewed source"
    ])

    commit = git!(directory, ["rev-parse", "HEAD"]) |> String.trim()
    repository = "https://example.invalid/synthetic-native-library.git"

    reviewed = %{
      synthetic: %{repository: repository, commit: commit, source_hashes: %{}}
    }

    lock = %{synthetic: {:git, repository, commit, [ref: commit]}}
    paths = %{synthetic: directory}
    assert :ok = Security.verify_provenance(lock, paths, reviewed)

    wrong_lock = %{synthetic: {:git, repository, commit, [ref: "unreviewed-branch"]}}
    assert {:error, _} = Security.verify_provenance(wrong_lock, paths, reviewed)

    File.write!(Path.join(directory, "lib/guard.ex"), "synthetic altered security source")
    assert {:error, _} = Security.verify_provenance(lock, paths, reviewed)

    File.write!(Path.join(directory, "lib/guard.ex"), source)
    File.write!(Path.join(directory, "lib/hidden.ex"), "synthetic ignored extra runtime source")
    assert {:error, _} = Security.verify_provenance(lock, paths, reviewed)
  end

  @tag tmp_dir: true
  test "reviewed security source hashes fail after source tampering", %{tmp_dir: directory} do
    original = "synthetic reviewed security source"
    File.write!(Path.join(directory, "helpers.ex"), original)
    expected = :crypto.hash(:sha256, original) |> Base.encode16(case: :lower)
    assert :ok = Security.validate_source_hashes(directory, %{"helpers.ex" => expected})

    File.write!(Path.join(directory, "helpers.ex"), "synthetic unreviewed source")
    assert {:error, _} = Security.validate_source_hashes(directory, %{"helpers.ex" => expected})
    assert {:error, _} = Security.validate_source_hashes(directory, %{"missing.ex" => expected})
  end

  defp policy(vaults \\ []) do
    [cloak_inventory: :complete, cloak_vaults: vaults]
  end

  defp git!(directory, arguments) do
    {output, 0} = System.cmd("git", arguments, cd: directory, stderr_to_stdout: true)
    output
  end

  defp with_extra_vault(config, fun) do
    module = __MODULE__.ExtraVault
    previous = Application.fetch_env(:ash_lotus, module)

    Code.compile_quoted(
      quote do
        defmodule unquote(module) do
          use Cloak.Vault, otp_app: :ash_lotus
        end
      end
    )

    if is_nil(config),
      do: Application.delete_env(:ash_lotus, module),
      else: Application.put_env(:ash_lotus, module, config)

    try do
      fun.()
    after
      restore_env(:ash_lotus, module, previous)
      :code.purge(module)
      :code.delete(module)
    end
  end

  defp restore_env(app, module, {:ok, config}), do: Application.put_env(app, module, config)
  defp restore_env(app, module, :error), do: Application.delete_env(app, module)

  defp safe_config do
    [ciphers: [default: {Cloak.Ciphers.AES.GCM, tag: "synthetic-gcm-v1", key: <<0::256>>}]]
  end

  defp unsafe_config do
    [ciphers: [legacy: {Cloak.Ciphers.AES.CTR, tag: "synthetic-ctr-v1", key: <<0::256>>}]]
  end
end
