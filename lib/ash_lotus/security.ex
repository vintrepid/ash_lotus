# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule AshLotus.Security do
  @moduledoc """
  Fail-closed checks for the reviewed distribution's security boundary.

  A complete vault inventory is a host declaration, not a blanket certification
  of arbitrary Cloak callbacks. Only SolidAsh's natively guarded vault is trusted
  for the conditional CTR advisory acknowledgement. Additional compiled custom
  vaults, configured vaults or active vaults require separate reviewed enforcement.
  No vault, worker or application is started by these checks.
  """

  @cloak_advisory "CVE-2026-95105"
  @reviewed_cloak_version "1.1.4"
  @hex_floors [
    decimal: "3.1.2",
    spark: "2.7.6",
    ash_authentication_phoenix: "2.17.4",
    mint: "1.10.2"
  ]

  @doc """
  Loads resolved OTP application metadata without starting applications.

  Native Mix dependencies explicitly declaring `app: false` are assets, not
  OTP applications. Only that explicit option excludes a dependency; a
  `compile: false` option or a missing `.app` file never hides a real app.
  The owning root application is always loaded and checked. Dependency status
  is deliberately not trusted because Mix's cached status may be stale.
  """
  def load_application_metadata(dependencies, root_application) when is_list(dependencies) do
    with true <- valid_application?(root_application),
         true <- Enum.all?(dependencies, &valid_native_dependency?/1),
         applications =
           dependencies
           |> Enum.reject(&(Keyword.get(&1.opts, :app) == false))
           |> Enum.map(& &1.app),
         :ok <- load_metadata_apps(Enum.uniq(applications ++ [root_application])) do
      {:ok, Map.new(applications, &{&1, Application.spec(&1, :vsn)})}
    else
      _ -> {:error, "Required application metadata could not be safely loaded"}
    end
  rescue
    _ -> {:error, "Required application metadata could not be safely loaded"}
  end

  def load_application_metadata(_, _),
    do: {:error, "Required application metadata could not be safely loaded"}

  @doc "Validate explicit host inventory through SolidAsh's native ongoing guard."
  def validate_vault_inventory(policy) when is_list(policy) do
    with true <- Keyword.keyword?(policy),
         true <- length(Keyword.keys(policy)) == length(Enum.uniq(Keyword.keys(policy))),
         :complete <- Keyword.get(policy, :cloak_inventory),
         declared when is_list(declared) <- Keyword.get(policy, :cloak_vaults),
         true <- Enum.all?(declared, &valid_inventory_entry?/1),
         true <- length(declared) == length(Enum.uniq(declared)),
         true <- Code.ensure_loaded?(SolidAsh.Security),
         true <- function_exported?(SolidAsh.Security, :validate_inventory, 1) do
      apply(SolidAsh.Security, :validate_inventory, [declared])
    else
      _ -> {:error, "An explicit complete Cloak inventory and native GCM-only guard are required"}
    end
  rescue
    _ -> {:error, "The native vault inventory could not be safely validated"}
  end

  def validate_vault_inventory(_),
    do: {:error, "An explicit complete Cloak vault inventory is required"}

  @doc "Reject inherited or project-wide overrides before the conditional audit."
  def validate_audit_overrides(hex_config, environment)
      when is_list(hex_config) and is_map(environment) do
    if Keyword.keyword?(hex_config) and
         length(Keyword.keys(hex_config)) == length(Enum.uniq(Keyword.keys(hex_config))) and
         Enum.all?([:ignore_advisories, :ignore_retirements], fn key ->
           Keyword.get(hex_config, key, []) == []
         end) and
         Enum.all?(["HEX_IGNORE_ADVISORIES", "HEX_IGNORE_RETIREMENTS"], fn key ->
           Map.get(environment, key) in [nil, ""]
         end) do
      :ok
    else
      {:error,
       "Remove existing Hex advisory/retirement overrides; the gate owns its narrow acknowledgement"}
    end
  end

  def validate_audit_overrides(_, _), do: {:error, "Invalid Hex audit configuration"}

  @doc "Exact audit environment, used only after inventory and provenance succeed."
  def audit_environment do
    [
      {"HEX_IGNORE_ADVISORIES", @cloak_advisory},
      {"HEX_IGNORE_RETIREMENTS", nil}
    ]
  end

  @doc "Preserve the native audit exit status; unrelated advisories cannot become success."
  def validate_audit_result(0), do: :ok
  def validate_audit_result(_), do: {:error, "The native Hex advisory/retirement audit failed"}

  @doc "Do not extend this advisory acknowledgement to an unreviewed Cloak release."
  def validate_advisory_scope(versions) do
    if to_string(Map.get(versions, :cloak)) == @reviewed_cloak_version,
      do: :ok,
      else: {:error, "The narrowly acknowledged Cloak release has not been reviewed"}
  end

  @doc "Require the reviewed minimum patched Hex versions in loaded application metadata."
  def validate_hex_floors(versions) when is_map(versions) do
    Enum.reduce_while(@hex_floors, :ok, fn {app, floor}, :ok ->
      case Map.get(versions, app) do
        nil ->
          {:halt, {:error, "Patched Hex dependency metadata is missing for #{app}"}}

        version ->
          if Version.match?(to_string(version), ">= #{floor}"),
            do: {:cont, :ok},
            else: {:halt, {:error, "The reviewed patched Hex minimum is not met for #{app}"}}
      end
    end)
  rescue
    _ -> {:error, "Patched Hex dependency metadata could not be validated"}
  end

  @doc "Verify fetched Git source and lock provenance against immutable reviewed refs."
  def verify_provenance(lock, paths, reviewed) do
    Enum.reduce_while(reviewed, :ok, fn {dependency, provenance}, :ok ->
      case verify_dependency(dependency, provenance, lock, paths) do
        :ok -> {:cont, :ok}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  @doc "Compare reviewed native security source hashes without evaluating source."
  def validate_source_hashes(path, hashes) when is_binary(path) and is_map(hashes) do
    Enum.reduce_while(hashes, :ok, fn {file, expected}, :ok ->
      with {:ok, source} <- File.read(Path.join(path, file)),
           actual <- :crypto.hash(:sha256, source) |> Base.encode16(case: :lower),
           true <- actual == expected do
        {:cont, :ok}
      else
        _ -> {:halt, {:error, "A reviewed native security source hash does not match"}}
      end
    end)
  end

  defp verify_dependency(dependency, provenance, lock, paths) do
    entry = Map.get(lock, dependency) || Map.get(lock, to_string(dependency))
    path = Map.get(paths, dependency)

    with %{commit: commit, repository: repository, source_hashes: hashes} <- provenance,
         true <- is_binary(commit) and Regex.match?(~r/\A[0-9a-f]{40}\z/, commit),
         {:git, ^repository, ^commit, options} <- entry,
         ^commit <- Keyword.get(options, :ref),
         true <- is_binary(path),
         {head, 0} <- System.cmd("git", ["rev-parse", "HEAD"], cd: path, stderr_to_stdout: true),
         true <- String.trim(head) == commit,
         {_, 0} <-
           System.cmd("git", ["diff", "--quiet", "HEAD", "--", "lib", "mix.exs"], cd: path),
         {untracked, 0} <-
           System.cmd("git", ["ls-files", "--others", "--", "lib", "mix.exs"], cd: path),
         "" <- String.trim(untracked),
         true <- dependency not in [:ash_authentication, :solid_ash] or map_size(hashes) > 0,
         :ok <- validate_native_version(dependency, provenance),
         :ok <- validate_source_hashes(path, hashes) do
      :ok
    else
      _ -> {:error, "Reviewed immutable Git provenance failed for #{dependency}"}
    end
  rescue
    _ -> {:error, "Reviewed immutable Git provenance could not be verified for #{dependency}"}
  end

  defp valid_inventory_entry?({app, module}) when is_atom(app) and is_atom(module),
    do: app not in [nil, true, false] and module not in [nil, true, false]

  defp valid_inventory_entry?(_), do: false

  defp valid_application?(application),
    do: is_atom(application) and application not in [nil, true, false]

  defp valid_native_dependency?(%Mix.Dep{app: application, opts: options}) do
    valid_application?(application) and is_list(options) and Keyword.keyword?(options)
  end

  defp valid_native_dependency?(_), do: false

  defp load_metadata_apps(applications) do
    Enum.reduce_while(applications, :ok, fn application, :ok ->
      case Application.load(application) do
        :ok -> {:cont, :ok}
        {:error, {:already_loaded, ^application}} -> {:cont, :ok}
        _ -> {:halt, :error}
      end
    end)
  end

  defp validate_native_version(dependency, %{version_floor: floor}) do
    case Application.spec(dependency, :vsn) do
      nil ->
        {:error, "Native dependency version metadata is missing"}

      version ->
        if Version.match?(to_string(version), ">= #{floor}"),
          do: :ok,
          else: {:error, "Native dependency patched version floor is not met"}
    end
  end

  defp validate_native_version(_, _), do: :ok
end
