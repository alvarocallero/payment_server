import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :payment_server, PaymentServer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  #  database: "payment_server_test",
  database: "payment_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# EctoShort database configuration
config :ecto_shorts, repo: PaymentServer.Repo, error_module: EctoShorts.Actions.Error

# All the possible currencies that the system can handle
config :payment_server, supported_currencies: ["UYU", "USD", "EUR"]

# AlphaVantage API configuration
config :payment_server,
#  alpha_vantage_api_host: "http://localhost:4001/",
  alpha_vantage_api_host: "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=UYU&apikey=Q9GU6BHZSJ9R2LO2",
  alpha_vantage_api_key: "Q9GU6BHZSJ9R2LO2",
  alpha_vantage_api_call_period: 10_000,
  alpha_vantage_api_max_retries: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :payment_server, PaymentServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "l14VQxxPz/hkS7EO3hOG+c0rpgeB0HgdAwuhY3cwrt3RIQXPAhWfTemIiwRSVBWB",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
