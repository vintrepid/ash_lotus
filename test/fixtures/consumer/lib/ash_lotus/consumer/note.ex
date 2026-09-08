# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.Consumer.Note do
  @moduledoc false

  use Ash.Resource,
    data_layer: :embedded,
    validate_domain_inclusion?: false

  actions do
    defaults(create: [:title])
  end

  attributes do
    uuid_v7_primary_key(:id)

    attribute :title, :string do
      allow_nil?(false)
      public?(true)
    end
  end
end
