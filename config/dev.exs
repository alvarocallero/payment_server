import Config

# Configure your database
config :payment_server, PaymentServer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "payment_server_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# EctoShort database configuration
config :ecto_shorts, repo: PaymentServer.Repo, error_module: EctoShorts.Actions.Error

# All the possible currencies that the system can handle
config :payment_server, supported_currencies: ["UYU", "USD", "EUR"]

# AlphaVantage API configuration
config :payment_server,
  alpha_vantage_api_host: "https://www.alphavantage.co/",
  alpha_vantage_api_key: "Q9GU6BHZSJ9R2LO2",
  alpha_vantage_api_call_period: 5_000

# Configuration for log level
config :logger, :console, level: :debug, format: "[$level] [$date] [$time] $message\n\n"

# For development, we disable any cache and enable
# debugging and code reloading.
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :payment_server, PaymentServerWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "I+//lJ7gilz2KRoc0x7a1OHDB7S2lAy5VLuPm8WBpmwVu02bfyPmRhPltg+on3ix",
  watchers: []

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
