defmodule PaymentServer.Currencies.ApiTest do
  use ExUnit.Case

  alias PaymentServer.Currencies.Api

  describe "&fetch_exchange_rates/2" do
    test "get the exchange rate between supported currencies" do
      api_call_result = Api.fetch_exchange_rates("USD", "UYU")
      assert {:ok, exchange_rate} = api_call_result
      assert is_float(String.to_float(exchange_rate))
    end
  end
end
