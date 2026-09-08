# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.TestPeer do
  @moduledoc false

  def create!(resource, attributes) do
    resource
    |> Ash.Changeset.for_create(:create, attributes)
    |> Ash.create!()
  end
end
