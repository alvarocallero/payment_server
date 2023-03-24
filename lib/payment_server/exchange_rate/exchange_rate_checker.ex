defmodule PaymentServer.ExchangeRate.ExchangeRateChecker do
  @moduledoc """
  GenServer process that checks if the exchange rate for all the currencies of the app has changed.
  To identify when the exchange rate of all the currencies has changed, the state of the GenServer will store
  2 fields:
    1. exchange_rate_monitors_amount: the amount of exchange rate monitors in the app.
    2. exchange_rate_monitors_updates: the amount of exchange rate monitors that have updated the exchange rate that is handled.
       The initial value is 0.
  So when exchange_rate_monitors_updates === exchange_rate_monitors_amount then it can be deducted that all the exchange rates has been updated.
  """

  use Agent

  use GenServer, restart: :permanent

  require Logger

  alias PaymentServer.ExchangeRate.ExchangeRateMonitor

  @default_name PaymentServer.ExchangeRate.ExchangeRateChecker
  @api_call_period Application.compile_env(:payment_server, :alpha_vantage_api_call_period)

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @default_name)
    Logger.debug("ExchangeRateChecker started")
    GenServer.start_link(@default_name, %{}, opts)
  end

  @doc """
  This function will be called by the Exchange Rate Monitors to notify that the exchange rate for the pair of currencies
  that is holding has changed.
  """
  def update_exchange_rate_counter(name \\ @default_name) do
    GenServer.cast(name, {:increase_exchange_rate_monitor_update})
  end

  @doc """
  To initialize the state, the number of possible currencies combination without repetitions are fetched, so
  the amount of exchange rate monitors can be obtained, and this value will be stored in exchange_rate_monitors_amount.
  The value of exchange_rate_monitors_updates is 0 when the GenServer starts since no exchange rate monitor has
  sent a message to notify that its exchange rate has been updated.
  """
  def init(_state) do
    available_currencies_combinations =
      ExchangeRateMonitor.get_currencies_combinations(
        PaymentServer.Payments.get_available_currencies(),
        2
      )

    state = %{
      exchange_rate_monitors_amount: length(available_currencies_combinations),
      exchange_rate_monitors_updates: 0
    }

    send(self(), :check_for_exchange_rate_updates)
    {:ok, state}
  end

  @doc """
  This function will check if the exchange rate of all the currencies has changed or not.
  """
  def handle_info(:check_for_exchange_rate_updates, state) do
    if Map.get(state, :exchange_rate_monitors_amount) ===
         Map.get(state, :exchange_rate_monitors_updates) do
      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        "Exchange rate for all currencies has changed",
        all_exchange_rates_changed: "all_exchange_rates_changed"
      )
    end

    new_state = %{state | exchange_rate_monitors_updates: 0}
    Process.send_after(self(), :check_for_exchange_rate_updates, @api_call_period)
    {:noreply, new_state}
  end

  def handle_cast({:increase_exchange_rate_monitor_update}, state) do
    new_state = %{
      state
      | exchange_rate_monitors_updates: Map.get(state, :exchange_rate_monitors_updates) + 1
    }

    {:noreply, new_state}
  end
end
