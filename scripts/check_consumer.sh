#!/bin/sh
# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

set -eu

cd "$(dirname "$0")/../test/fixtures/consumer"

mix deps.get
mix format --check-formatted
mix test
MIX_ENV=prod mix compile --warnings-as-errors
MIX_ENV=prod mix release --overwrite
_build/prod/rel/ash_lotus_consumer/bin/ash_lotus_consumer eval \
  'AshLotus.Consumer.ReleaseCheck.run!(); IO.puts("AshLotus consumer release check passed")'
