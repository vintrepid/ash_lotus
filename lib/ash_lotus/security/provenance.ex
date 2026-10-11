# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule AshLotus.Security.Provenance do
  @moduledoc false

  # These are review anchors, not moving branch declarations. Native owning
  # library checks must pass before this bill of materials can advance.
  def reviewed do
    %{
      ash: %{
        repository: "https://github.com/vintrepid/ash_lotus_core.git",
        commit: "070f3e382070699b48f7e823ba004022a7b69d2b",
        source_hashes: %{}
      },
      korero: %{
        repository: "https://github.com/vintrepid/korero.git",
        commit: "49e23d8724611e0c10e64d0dde4635760aaa41e9",
        source_hashes: %{}
      },
      ash_authentication: %{
        repository: "https://github.com/vintrepid/ash_authentication.git",
        commit: "f0f1eb34e20ce0cdcfd11ef4b07585b3b9e61368",
        version_floor: "4.15.0",
        source_hashes: %{
          "lib/ash_authentication.ex" =>
            "21f7a008640cc896e1d7109f983e9ce448b7363a5bf8aa713e14b514ad181716",
          "lib/ash_authentication/plug/helpers.ex" =>
            "e66b1cba8b643dc13bc697f4718ecda207a607623adfb48b1a993b8499556d8a",
          "lib/ash_authentication/token_resource/is_revoked.ex" =>
            "c4f4f45a43759445cacaf7079e27f5150713028cc99a99812f6f24996c064b84",
          "lib/ash_authentication/token_resource/is_revoked_preparation.ex" =>
            "ce85c9c0efa03f87f3ba655e83997550f54c43c795bb19822dba958fa042e344",
          "lib/ash_authentication/token_resource/actions.ex" =>
            "4c03537f7fae12cd8c44d494d8a4d91265571b15686bb8c2c39537e8b33db760",
          "lib/ash_authentication/token_resource/revoke_token_change.ex" =>
            "65be85cf4bbef06de141a41a3f101bd480c1afc97ae5c6a4a7f75171dbce96d3",
          "lib/ash_authentication/jwt.ex" =>
            "50c0cea1a843205b90ecffc62ee0c763ab1337577b66a1ab8f3ac669c8d926a0",
          "lib/ash_authentication/strategies/magic_link/sign_in_change.ex" =>
            "b5978a2c989e04a54c7b47018bcd477e1596e0e5c5dcf5a9b702165449b72d4c",
          "lib/ash_authentication/strategies/magic_link/sign_in_preparation.ex" =>
            "48a1fe172538133017b52af4b775e921a78c506e4acdeecc3b3cfbb1459bf7b7",
          "lib/ash_authentication/strategies/password/actions.ex" =>
            "b4fa9787ff4385fb49631b5ed0883ea661ef76b00f997cb65b7eba65464e8f2c",
          "lib/ash_authentication/strategies/password/sign_in_with_token_preparation.ex" =>
            "3860ec83040aff784e308404b55336bb443450a56489864f960e224bdee173c6",
          "lib/ash_authentication/add_ons/confirmation/actions.ex" =>
            "7a245678a125a67b72d68fd8dc5a4183ef71c19f44cafb4bf5b3ae9a756f4284",
          "lib/ash_authentication/strategies/remember_me/token/helpers.ex" =>
            "60ef4e07202752dc3eb25e16df8f1ab3e86dfad5d656d3ee94bbcea9d5cc0f2a",
          "lib/ash_authentication/strategies/api_key/sign_in_preparation.ex" =>
            "2347d42e490591b536c2ef572bd46890faf168a9fac22fe63c1b2f472f08abfc",
          "lib/ash_authentication/strategies/oauth2/sign_in_preparation.ex" =>
            "45da1659e006247a5340c14a9237a384c6e7ee0c7047a83edd1d797cf817aa79",
          "test/ash_authentication/fork_security_regression_test.exs" =>
            "36697b3715be455a9bef7c4874bcd5e17aee2c3585087c7c88e95534bc68178a",
          "test/ash_authentication/single_use_token_concurrency_test.exs" =>
            "ce1dd5f89102fb54f80c805c00026b5d6c148c5959328a757095265d0c9180fc",
          "test/ash_authentication/plug/helpers_test.exs" =>
            "e44c320d0f7c7562d69f98757c5c122406fa894c59afeb633798673a5835e197",
          "test/ash_authentication/token_resource/actions_test.exs" =>
            "0b1277d5a0b53fb39a6265847476974542c81b9f15742287fa4107aa9136b728"
        }
      },
      solid_ash: %{
        repository: "https://github.com/vintrepid/solid_ash.git",
        commit: "2e3ec1397fc0eef985fb9bff6a5a134ee453a13c",
        source_hashes: %{
          "lib/solid_ash/vault.ex" =>
            "3a90074eb78d425db90bca1fb5ee9712130ba32c6d2725a04aac86416a899545",
          "lib/solid_ash/security.ex" =>
            "057a5973f4accc7f60e5a8cc4350c794c111fce01f71c51ecb26eafb7ac4d8cd",
          "lib/solid_ash/vault/ciphertext_error.ex" =>
            "629b6d34526e5e555db70a529ea2ba2f42efd48ee287a4ec1bdcf6e35727ee23"
        }
      }
    }
  end
end
