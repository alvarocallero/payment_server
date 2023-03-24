defmodule PaymentServer.Currencies.CurrenciesFormatterTest do
  use ExUnit.Case

  alias PaymentServer.Currencies.CurrenciesFormatter

  describe "&parse_from_float_string_to_integer/1" do
    test "parse a string float number to an integer number" do
      parsed_number = CurrenciesFormatter.parse_from_float_string_to_integer("150.50")
      assert 15_050 == parsed_number
    end
  end

  describe "&parse_from_float_to_integer/1" do
    test "parse a float number to an integer number" do
      parsed_number = CurrenciesFormatter.parse_from_float_to_integer(150.50)
      assert 15_050 == parsed_number
    end
  end

  describe "&remove_last_two_digits_of_integer/1" do
    test "remove the last two digits of an integer number" do
      parsed_number = CurrenciesFormatter.remove_last_two_digits_of_integer(15_050)
      assert 150 == parsed_number
    end
  end

  describe "&parse_from_integer_to_float/1" do
    test "parse an integer number to a float number" do
      parsed_number = CurrenciesFormatter.parse_from_integer_to_float(15_050)
      assert 150.50 == parsed_number
    end
  end

  describe "&parse_from_float_to_string/1" do
    test "parse a float number to string" do
      parsed_number = CurrenciesFormatter.parse_from_float_to_string(150.56878544)
      assert "150.57" == parsed_number
    end
  end
end
