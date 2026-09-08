# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.Consumer.ReleaseCheckTest do
  use ExUnit.Case

  test "the curated graph and an independent Ash peer work in the host runtime" do
    assert :ok = AshLotus.Consumer.ReleaseCheck.run!()
  end
end
