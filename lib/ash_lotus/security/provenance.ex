# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule AshLotus.Security.Provenance do
  @moduledoc false
  def reviewed do
    %{
      ash: %{
        commit: "216b84abb9fc59df778211b4b932cf14552eb5a2",
        repository: "https://github.com/vintrepid/ash_lotus_core.git",
        source_hashes: %{}
      },
      ash_authentication: %{
        commit: "eb13b2bda797f20645d54181943e10162be8d240",
        repository: "https://github.com/vintrepid/ash_authentication.git",
        source_hashes: %{
          "lib/ash_authentication.ex" =>
            "707b218a905c0f58070e868c15fbfadb81c73dac0503ef5d502b3d116f456125",
          "lib/ash_authentication/add_ons/confirmation/actions.ex" =>
            "7a245678a125a67b72d68fd8dc5a4183ef71c19f44cafb4bf5b3ae9a756f4284",
          "lib/ash_authentication/jwt.ex" =>
            "50c0cea1a843205b90ecffc62ee0c763ab1337577b66a1ab8f3ac669c8d926a0",
          "lib/ash_authentication/plug/helpers.ex" =>
            "e66b1cba8b643dc13bc697f4718ecda207a607623adfb48b1a993b8499556d8a",
          "lib/ash_authentication/strategies/api_key/sign_in_preparation.ex" =>
            "2347d42e490591b536c2ef572bd46890faf168a9fac22fe63c1b2f472f08abfc",
          "lib/ash_authentication/strategies/magic_link/sign_in_change.ex" =>
            "6aec40dcc2ccd63256180c6a0c85038b1366c202db912a872fe7fcc0bc4b27e0",
          "lib/ash_authentication/strategies/magic_link/sign_in_preparation.ex" =>
            "26abe2b08784aab8b3e76d8e74ff37f2203b41c00cec1d6ddf6f145fba7d0ccf",
          "lib/ash_authentication/strategies/oauth2/sign_in_preparation.ex" =>
            "0a39657f743ca7f3fbebc7d1309cb21af1372c2c6c2d72b0586a45eb2d5ac67b",
          "lib/ash_authentication/strategies/password/actions.ex" =>
            "89795e2c8ca0bd93b9ad71d012fe315a2b67157113cd906792925b14f720af9e",
          "lib/ash_authentication/strategies/password/sign_in_with_token_preparation.ex" =>
            "3860ec83040aff784e308404b55336bb443450a56489864f960e224bdee173c6",
          "lib/ash_authentication/strategies/remember_me/token/helpers.ex" =>
            "60ef4e07202752dc3eb25e16df8f1ab3e86dfad5d656d3ee94bbcea9d5cc0f2a",
          "lib/ash_authentication/token_resource/actions.ex" =>
            "e1ff2c50153d0782c75dd53e50a75bb2f23cb54ce57b7dc8aa24194d24dbd7f6",
          "lib/ash_authentication/token_resource/is_revoked.ex" =>
            "c4f4f45a43759445cacaf7079e27f5150713028cc99a99812f6f24996c064b84",
          "lib/ash_authentication/token_resource/is_revoked_preparation.ex" =>
            "ce85c9c0efa03f87f3ba655e83997550f54c43c795bb19822dba958fa042e344",
          "lib/ash_authentication/token_resource/revoke_token_change.ex" =>
            "65be85cf4bbef06de141a41a3f101bd480c1afc97ae5c6a4a7f75171dbce96d3",
          "test/ash_authentication/fork_security_regression_test.exs" =>
            "36697b3715be455a9bef7c4874bcd5e17aee2c3585087c7c88e95534bc68178a",
          "test/ash_authentication/plug/helpers_test.exs" =>
            "e44c320d0f7c7562d69f98757c5c122406fa894c59afeb633798673a5835e197",
          "test/ash_authentication/single_use_token_concurrency_test.exs" =>
            "ce1dd5f89102fb54f80c805c00026b5d6c148c5959328a757095265d0c9180fc",
          "test/ash_authentication/token_resource/actions_test.exs" =>
            "dec5cf1531429c6d8c9cc67196633a24060a7a9c6cf3b63c5f44b337ea1272a3"
        },
        version_floor: "4.15.1"
      },
      korero: %{
        commit: "833e4f0e426ed5cfdba5344515befe2e71e2e460",
        repository: "https://github.com/vintrepid/korero.git",
        source_hashes: %{}
      },
      solid_ash: %{
        commit: "8c2120d3425512ac086066da9088c2c65c832aeb",
        repository: "https://github.com/vintrepid/solid_ash.git",
        source_hashes: %{
          "lib/solid_ash/security.ex" =>
            "35317a016d2c51adc014ad4bfcab64db6477e136ae0f41815a1c037a888be390",
          "lib/solid_ash/vault.ex" =>
            "3a90074eb78d425db90bca1fb5ee9712130ba32c6d2725a04aac86416a899545",
          "lib/solid_ash/vault/ciphertext_error.ex" =>
            "629b6d34526e5e555db70a529ea2ba2f42efd48ee287a4ec1bdcf6e35727ee23"
        }
      }
    }
  end
end
