defmodule PaymentServer.ExchangeRate.ExchangeRateHolder do
  @moduledoc """
  Agent that will hold the exchange rate for a pair of currencies.
  """
  use Agent

  require Logger

  @default_name PaymentServer.ExchangeRate.ExchangeRateHolder

  def start_link(args) do
    from_currency = Keyword.get(args, :from_currency)
    to_currency = Keyword.get(args, :to_currency)
    process_name = "#{from_currency}=>#{to_currency}"
    Logger.debug("Starting a new ExchangeRateHolder | ExchangeRateHolder name: #{process_name}")
    Agent.start_link(fn -> 0 end, name: via(process_name))
  end

  def get_exchange_rate(name \\ @default_name) do
    Agent.get(name, & &1)
  end

  def update_exchange_rate(name \\ @default_name, new_exchange_rate) do
    Agent.update(name, fn _ -> new_exchange_rate end)

  end

  defp via(value) do
    {:via, Registry, {PaymentServer.JobRegistry, value}}
  end

end
