# SPDX-FileCopyrightText: 2026 Vince Nibler
#
# SPDX-License-Identifier: MIT

defmodule AshLotus do
  @moduledoc """
  The dependency contract for the curated Ash stack used by Lotus applications.

  Host applications continue to use the distributed libraries' native APIs.
  AshLotus does not wrap or re-export those APIs; its public contract is the
  compatible dependency graph declared by its Mix project.
  """
end
