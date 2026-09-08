# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

defmodule AshLotus.Consumer.PrecheckIdentities do
  @moduledoc false
  use Spark.Dsl.Transformer

  @impl true
  def transform(dsl) do
    identity = Ash.Resource.Info.identity(dsl, :unique_request_key)
    identity = %{identity | pre_check_with: AshLotus.Consumer.Domain}

    {:ok,
     Spark.Dsl.Transformer.replace_entity(dsl, [:identities], identity, fn candidate ->
       candidate.name == :unique_request_key
     end)}
  end
end

defmodule AshLotus.Consumer.EtsIdentities do
  @moduledoc false
  use Spark.Dsl.Extension, transformers: [AshLotus.Consumer.PrecheckIdentities]
end

defmodule AshLotus.Consumer.Task do
  @moduledoc false

  use Ash.Resource,
    domain: AshLotus.Consumer.Domain,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshLotus.Consumer.EtsIdentities],
    fragments: [Korero.Task]

  ets do
    private?(true)
  end
end

defmodule AshLotus.Consumer.Domain do
  @moduledoc false

  use Ash.Domain

  resources do
    resource(AshLotus.Consumer.Task)
  end
end
