defmodule PaymentServer.Currencies.Api do
  @moduledoc """
  Provides functionality to make API calls using the Finch library.
  """

  require Logger
  alias PaymentServer.ErrorHandling

  @api_url Application.compile_env(:payment_server, :alpha_vantage_api_host)
  @api_key Application.compile_env(:payment_server, :alpha_vantage_api_key)

  @type from_currency() :: String.t()
  @type to_currency() :: String.t()
  @type exchange_rate() :: integer()

  @doc """
  Gets the exchange rate between from_currency() and to_currency() making a call to AlphaVantage API.
  """

  @spec fetch_exchange_rates(from_currency(), to_currency()) ::
          {:ok, exchange_rate()} | {:error, String.t()}
  def fetch_exchange_rates(from_currency, to_currency) do
    url = """
          #{@api_url}\
          query?function=CURRENCY_EXCHANGE_RATE\
          &from_currency=#{from_currency}\
          &to_currency=#{to_currency}\
          &apikey=#{@api_key}\
          """
    url
    |> make_http_get_request
    |> parse_api_response
  end

  defp make_http_get_request(url) do
    response = :get |> Finch.build(url) |> Finch.request(FinchAPI)
    case response do
      {:ok, response} ->
        if String.contains?(response.body, "Realtime Currency Exchange Rate") do
          {:ok, response}
        else
          ErrorHandling.build_error_response(response.body, "make_http_get_request")
        end

      {:error, msg} ->
        ErrorHandling.build_error_response(msg.reason, "make_http_get_request")
    end
  end

  defp parse_api_response(response) do
    case response do
      {:ok, body} ->
        exchange_rate =
          body
          |> Map.from_struct()
          |> Map.get(:body)
          |> Jason.decode!()
          |> get_in(["Realtime Currency Exchange Rate", "5. Exchange Rate"])

        {:ok, exchange_rate}

      {:error, msg} ->
        ErrorHandling.build_error_response(Map.get(msg, :details), "parse_api_response")
    end
  end
end
