defmodule PaymentServer.Payments do
  @moduledoc """
  This module contains payment transfer money logic related.
  """

  alias PaymentServer.PaymentsRepository
  alias PaymentServer.ExchangeRate.{ExchangeRateMonitor, ExchangeRateHolder}
  alias PaymentServer.Currencies.CurrenciesFormatter
  alias PaymentServer.ErrorHandling


  @available_currencies Application.compile_env(:payment_server, :supported_currencies)


  @spec get_available_currencies() :: list(String.t())
  def get_available_currencies, do: @available_currencies

  require Logger
  @doc """
  Make money transfers between 2 wallets. \
  If the origin and destination currency are the same, then no amount of transformation is needed. \
  If the origin and destination currency are different, then the exchange rate is used to achieve the transfer.
  Since the app only stores the exchange rate between 2 currencies in only 1 direction (currency_1=>currency_2),
  depending on the transfer direction the logic to get the final amount will make the multiplication or the division.
  """
  def transfer_money(%{
        origin_wallet: origin_wallet,
        destination_wallet: destination_wallet,
        amount: amount,
        from_currency: from_currency,
        to_currency: to_currency
      }) do

    #Get the exchange rate (if necessary) and calculate the new wallet balance
    {new_balance_origin_wallet, new_balance_destination_wallet} =
      calculate_new_wallet_balance(origin_wallet.balance,
                                  destination_wallet.balance,
                                  amount,
                                  from_currency,
                                  to_currency)

    #Update the origin and destination user wallet balance
    with {:ok, modified_origin_wallet} <-
           PaymentsRepository.update_wallet(%{id: origin_wallet.id, balance: new_balance_origin_wallet}),
         {:ok, modified_destination_wallet} <-
           PaymentsRepository.update_wallet(%{
             id: destination_wallet.id,
             balance: new_balance_destination_wallet
           }) do

      #Parse the balance to show as float format
      destination_wallet_float_balance =
        CurrenciesFormatter.parse_from_integer_to_float(modified_destination_wallet.balance)

      origin_wallet_float_balance =
        CurrenciesFormatter.parse_from_integer_to_float(modified_origin_wallet.balance)

      modified_origin_wallet = %{modified_origin_wallet | balance: origin_wallet_float_balance}

      modified_destination_wallet = %{
        modified_destination_wallet
      | balance: destination_wallet_float_balance
      }

      {:ok, [modified_origin_wallet, modified_destination_wallet]}
    end

  end

  @doc """
  Return the total value of all the wallets of a specific user in a specific currency.
  For the calculation, there are 2 situations:
  1. If the currency to be returned the total worth is the same that the wallet that is iterated, then
   the balance is returned.
  2. If the currency to be returned is not the same as the wallet that is iterated, then the conversion
   is applied, using the exchange rate for the specific currency.
  """
  def get_total_value_of_all_wallets(%{user: user, currency: to_currency}) do
    total_value =
      Enum.reduce(user.wallets, 0, fn wallet, acc ->
        if wallet.currency === to_currency do
          acc + wallet.balance
        else
          {conversion_direction, pid} =
            ExchangeRateMonitor.get_pid_of_exchange_rate_process(
              wallet.currency,
              to_currency
            )

          exchange_rate = ExchangeRateHolder.get_exchange_rate(pid)

          if conversion_direction === "=>" do
            acc +
              CurrenciesFormatter.remove_last_two_digits_of_integer(
                wallet.balance * exchange_rate
              )
          else
            acc + CurrenciesFormatter.parse_from_float_to_integer(wallet.balance / exchange_rate)
          end
        end
      end)

    {:ok, CurrenciesFormatter.parse_from_integer_to_float(total_value)}
  end

  def check_if_currency_is_supported(currency) do
    if Enum.member?(PaymentServer.Payments.get_available_currencies(), currency) do
      :ok
    else
      ErrorHandling.build_error_response(currency, "check_if_currency_is_supported")
    end
  end

  def check_if_amount_is_positive(amount) do
    if amount > 0 do
      :ok
    else
      ErrorHandling.build_error_response(
        CurrenciesFormatter.parse_from_float_to_string(amount),
        "check_if_amount_is_positive"
      )
    end
  end

  def check_if_user_has_enough_balance(wallet, transfer_amount) do
    integer_transfer_amount = CurrenciesFormatter.parse_from_float_to_integer(transfer_amount)

    if Map.get(wallet, :balance) >= integer_transfer_amount do
      :ok
    else
      ErrorHandling.build_error_response(
        CurrenciesFormatter.parse_from_float_to_string(transfer_amount),
        "check_if_user_has_enough_balance"
      )
    end
  end

  def check_if_user_already_has_wallet(user, currency) do
    if [] === Enum.filter(user.wallets, fn map -> map.currency === currency end) do
      :ok
    else
      ErrorHandling.build_error_response(
        %{user_id: user.id, currency: currency},
        "check_if_user_already_has_wallet"
      )
    end
  end

  defp calculate_new_wallet_balance(origin_wallet_balance, destination_wallet_balance, transfer_amount, from_currency, to_currency) do
      if from_currency === to_currency do
        {origin_wallet_balance - transfer_amount, destination_wallet_balance + transfer_amount}
      else
        new_balance_origin_wallet = origin_wallet_balance - transfer_amount

        {conversion_direction, pid} =
          ExchangeRateMonitor.get_pid_of_exchange_rate_process(
            from_currency,
            to_currency
          )

        exchange_rate = ExchangeRateHolder.get_exchange_rate(pid)

        if conversion_direction === "=>" do
          new_balance_destination_wallet =
            destination_wallet_balance +
              CurrenciesFormatter.remove_last_two_digits_of_integer(transfer_amount * exchange_rate)

          {new_balance_origin_wallet, new_balance_destination_wallet}
        else
          new_balance_destination_wallet =
            destination_wallet_balance +
              CurrenciesFormatter.parse_from_float_to_integer(transfer_amount / exchange_rate)

          {new_balance_origin_wallet, new_balance_destination_wallet}
        end
      end
  end
end
