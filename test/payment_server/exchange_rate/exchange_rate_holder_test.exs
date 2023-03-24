defmodule PaymentServer.ExchangeRate.ExchangeRateHolderTest do
  use ExUnit.Case

  alias PaymentServer.ExchangeRate.{ExchangeRateHolder, ExchangeRateMonitor}

  describe "&get_exchange_rate/0" do
    test "get the exchange rate from UYU to USD" do
      assert {conversion_direction, pid} =
               ExchangeRateMonitor.get_pid_of_exchange_rate_process("USD", "UYU")

      assert is_pid(pid)
      assert conversion_direction == "=>" or conversion_direction == "<="
      exchange_rate = ExchangeRateHolder.get_exchange_rate(pid)
      assert is_integer(exchange_rate)
    end

    test "update the exchange rate from USD to UYU" do
      assert {:ok, pid} = ExchangeRateHolder.start_link([from_currency: "USD", to_currency: "EUR"])
      ExchangeRateHolder.update_exchange_rate(pid, 4523)
      assert is_pid(pid)
      exchange_rate = ExchangeRateHolder.get_exchange_rate(pid)
      assert exchange_rate == 4523
      assert is_integer(exchange_rate)
    end
  end
end
