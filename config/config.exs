# SPDX-FileCopyrightText: 2026 Vince Nibler
# SPDX-License-Identifier: MIT

import Config

config :ash, default_string_length_count: :codepoints
config :solid_ash, ash_domains: [SolidAsh.Domain]
config :ex_money, auto_start_exchange_rate_service: false
