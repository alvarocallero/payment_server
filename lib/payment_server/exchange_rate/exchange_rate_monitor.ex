defmodule PaymentServer.ExchangeRate.ExchangeRateMonitor do
  @moduledoc """
  This module provides a Task implementation for handling the startup of processes that will be fetching the exchange rate,
  and updating the Agents that store that value.
  """

  use Task

  require Logger
  alias PaymentServer.ExchangeRate.{ExchangeRateHolder, ExchangeRateChecker}
  alias PaymentServer.Currencies.{Api, CurrenciesFormatter}

  @api_call_period Application.compile_env(:payment_server, :alpha_vantage_api_call_period)

  def start_link(arg \\ []) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  @doc """
  This function will trigger the fetch and update of the exchange rates.
  """
  def run(_arg) do
    available_currencies = PaymentServer.Payments.get_available_currencies()
    available_currencies
    |> get_currencies_combinations(2)
    |> fetch_exchange_rates()

  end

  @doc """
  This function returns the combination without repetitions of the elements of a list.
  """
  def get_currencies_combinations(list, n) do
    result = Enum.reduce(list, [], fn item, acc ->
      acc ++ Enum.map(acc, fn x -> [item | x] end) ++ [[item]]
    end)
    Enum.filter(result, fn x -> length(x) === n end)
  end

  @doc """
  Returns the pid of the Agent that holds the exchange rate for the provided currency, and the direction of the currency conversion.
  To locate the pid of the Agent that holds the desired exchange rate, the Registry.lookup operation is used,
  so if the attempt to find the Agent process with the name "currency_1=>currency_2" is a success, then the tuple {"=>", exchange_rate}
  is returned, otherwise, Registry.lookup is called again but with the process named "currency_2=>currency_1", and will return
  the tuple then the tuple {"<=", exchange_rate}.
  """
  def get_pid_of_exchange_rate_process(from_currency, to_currency) do
    registry = PaymentServer.JobRegistry
    key = "#{from_currency}=>#{to_currency}"

    case Registry.lookup(registry, key) do
      [] ->
        key = "#{to_currency}=>#{from_currency}"
        [{pid, _}] = Registry.lookup(registry, key)
        {"<=", pid}

      [{pid, _}] ->
        {"=>", pid}
    end
  end

  defp fetch_exchange_rates(currencies) do
    currencies
    |> Task.async_stream(fn(currencies) -> fetch_exchange_rate(currencies) end)
    |> Stream.run()
    :timer.sleep(@api_call_period)
    fetch_exchange_rates(currencies)
  end

  defp fetch_exchange_rate([from_currency | to_currency]) do
    Logger.debug("Fetching the exchange rate | currencies: #{from_currency}=>#{to_currency}")
    api_call_result = Api.fetch_exchange_rates(from_currency, hd(to_currency))
    case api_call_result do
      {:ok, fetched_exchange_rate} -> integer_new_exchange_rate = CurrenciesFormatter.
                                                              parse_from_float_string_to_integer(fetched_exchange_rate)
                                      {_, pid} = get_pid_of_exchange_rate_process(from_currency, to_currency)
                                      current_exchange_rate = ExchangeRateHolder.get_exchange_rate(pid)

                                      #update the exchange rate if it has changed
                                      if current_exchange_rate !== integer_new_exchange_rate do
                                        ExchangeRateHolder.update_exchange_rate(pid, integer_new_exchange_rate)

                                        #add 1 to the counter for the subscription for notify when all exchange rates
                                        #has changed
                                        ExchangeRateChecker.update_exchange_rate_counter()

                                        #trigger the subscription of the exchange rate for a specific currency
                                        Absinthe.Subscription.publish(
                                          PaymentServerWeb.Endpoint,
                                          %{
                                            from_currency: from_currency,
                                            to_currency: to_currency,
                                            value: CurrenciesFormatter.
                                                    parse_from_float_string_to_float(fetched_exchange_rate)
                                          },
                                          exchange_rate_changed: "exchange_rate_changed:#{to_currency}"
                                        )
                                        Absinthe.Subscription.publish(
                                          PaymentServerWeb.Endpoint,
                                          %{
                                            from_currency: from_currency,
                                            to_currency: to_currency,
                                            value: CurrenciesFormatter.
                                                      parse_from_float_string_to_float(fetched_exchange_rate)
                                          },
                                          exchange_rate_changed: "exchange_rate_changed:#{from_currency}"
                                        )
                                      end

      error -> error
    end

  end
end
