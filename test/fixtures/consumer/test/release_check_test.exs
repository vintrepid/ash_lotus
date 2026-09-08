# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus.Consumer.ReleaseCheckTest do
  use ExUnit.Case

  test "one dependency supplies a working Ash model and journal runtime" do
    assert :ok = AshLotus.Consumer.ReleaseCheck.run!()
  end
end
