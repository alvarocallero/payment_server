defmodule PaymentServer.Currencies.CurrenciesFormatter do
  @moduledoc """
  Provides different functions to parse and format between different types of numbers.
  """

  @spec parse_from_float_string_to_float(String.t()) :: float()
  def parse_from_float_string_to_float(string_number) do
    string_number
    |> String.to_float()
    |> Float.round(2)
  end

  @spec parse_from_float_string_to_integer(String.t()) :: integer()
  def parse_from_float_string_to_integer(string_number) do
    string_number
    |> String.to_float()
    |> parse_from_float_to_integer()
  end

  @spec parse_from_float_to_integer(float()) :: integer()
  def parse_from_float_to_integer(float_number) do
    float_number
    |> parse_from_float_to_string
    |> String.replace(".", "")
    |> String.to_integer()
  end

  @spec remove_last_two_digits_of_integer(integer()) :: integer()
  def remove_last_two_digits_of_integer(integer_number) do
    integer_number
    |> Integer.to_string()
    |> String.slice(0..-3)
    |> String.to_integer()
  end

  @spec parse_from_integer_to_float(integer()) :: float()
  def parse_from_integer_to_float(integer_number) do
    integer_number
    |> :erlang.float()
    |> Kernel./(100)
  end

  @spec parse_from_float_to_string(float()) :: String.t()
  def parse_from_float_to_string(float_number) do
    float_number
    |> Decimal.from_float()
    |> Decimal.round(2)
    |> Decimal.to_string()
  end
end
