defmodule PaymentServer.ExchangeRate.ExchangeRateCheckerTest do
  use ExUnit.Case

  alias PaymentServer.ExchangeRate.ExchangeRateChecker

  describe "&update_exchange_rate_counter/1" do
    test "update the counter for a exchange rate monitor" do
      result = ExchangeRateChecker.update_exchange_rate_counter()
      assert :ok == result
    end
  end
end
