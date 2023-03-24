defmodule PaymentServer.GraphqlHelper do
  @fields_to_fetch_from_user "
    id
    firstName
    lastName
    email
    wallets{
      id
      balance
      currency
    }
  "

  @fields_to_fetch_from_wallet "
    id
    balance
    currency
  "

  @fields_to_fetch_from_exchange_rate_subscription "
    value
    from_currency
    to_currency
  "
  @test_user_1 %{
    "first_name" => "Mad",
    "last_name" => "Max",
    "email" => "mad@max.com.uy"
  }

  @test_user_2 %{
    "first_name" => "Mark",
    "last_name" => "Weber",
    "email" => "mark@weber.com.uy"
  }

  def get_fields_to_fetch_from_user, do: @fields_to_fetch_from_user
  def get_fields_to_fetch_from_wallet, do: @fields_to_fetch_from_wallet

  def get_fields_to_fetch_from_exchange_rate_subscription,
    do: @fields_to_fetch_from_exchange_rate_subscription

  def get_test_user_1, do: @test_user_1
  def get_test_user_2, do: @test_user_2

  def get_test_wallet(balance, currency, user_id) do
    %{
      "balance" => balance,
      "currency" => currency,
      "user_id" => user_id
    }
  end

  def get_test_transfer_money(originUserId, fromCurrency, destinationUserId, toCurrency, amount) do
    %{
      "origin_user_id" => originUserId,
      "from_currency" => fromCurrency,
      "destination_user_id" => destinationUserId,
      "to_currency" => toCurrency,
      "amount" => amount
    }
  end
end
