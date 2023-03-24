defmodule PaymentServer.ExchangeRate.ExchangeRateMonitorTest do
  use ExUnit.Case

  alias PaymentServer.ExchangeRate.ExchangeRateMonitor

  describe "&get_pid_of_exchange_rate_process/2" do
    test "get the pid of different GenServers" do
      assert {conversion_direction_1, pid_1} =
               ExchangeRateMonitor.get_pid_of_exchange_rate_process("USD", "EUR")

      assert {conversion_direction_2, pid_2} =
               ExchangeRateMonitor.get_pid_of_exchange_rate_process("EUR", "USD")

      assert {"<=", pid_1} == {conversion_direction_1, pid_1}
      assert {"=>", pid_1} == {conversion_direction_2, pid_2}
      assert is_pid(pid_1)
      assert is_pid(pid_1)
    end
  end

  describe "&get_currencies_combinations/2" do
    test "get all the combinations without repetition taken by 2 of a list of currencies" do
      returned_3_combinations =
        ExchangeRateMonitor.get_currencies_combinations(["UYU", "USD", "EUR"], 2)

      returned_6_combinations =
        ExchangeRateMonitor.get_currencies_combinations(["UYU", "USD", "EUR", "ARS"], 2)

      returned_15_combinations =
        ExchangeRateMonitor.get_currencies_combinations(
          ["UYU", "USD", "EUR", "ARS", "COP", "BRL"],
          2
        )

      assert length(returned_3_combinations) == 3
      assert length(returned_6_combinations) == 6
      assert length(returned_15_combinations) == 15
    end
  end
end
