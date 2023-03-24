defmodule PaymentServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  alias PaymentServer.ExchangeRate.ExchangeRateMonitor
  alias PaymentServer.ExchangeRate.ExchangeRateHolder

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      PaymentServer.Repo,
      # Start the Telemetry supervisor
      PaymentServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PaymentServer.PubSub},
      # Start the Endpoint (http/https)
      PaymentServerWeb.Endpoint,
      # Start the GraphQL subscription process
      {Absinthe.Subscription, [PaymentServerWeb.Endpoint]},
      # Start the Finch API
      {Finch, name: FinchAPI},
      # Registry process to identify processes easily
      {Registry, keys: :unique, name: PaymentServer.JobRegistry},
      # Start a GenServer to check updates on all the currencies exchange rates
      PaymentServer.ExchangeRate.ExchangeRateChecker,
      # Start a task that will be in charge of running the get exchange rate process
      ExchangeRateMonitor,
    ] ++ create_agents_to_store_the_exchange_rates

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PaymentServer.Supervisor]
    Logger.info("Starting the Payment Server")
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PaymentServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp create_agents_to_store_the_exchange_rates do
    available_currencies = PaymentServer.Payments.get_available_currencies()
    available_currencies
    |> ExchangeRateMonitor.get_currencies_combinations(2)
    |> Enum.reduce([], fn [from_currency, to_currency], acc ->
      acc ++ [Supervisor.child_spec({ExchangeRateHolder, [from_currency: from_currency, to_currency: to_currency]},
        id: "exchange_rate_holder:#{from_currency}=>#{to_currency}")]
    end)
  end
end
