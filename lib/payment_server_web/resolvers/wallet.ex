defmodule PaymentServerWeb.Resolver.Wallet do
  @doc """
  Provides all the Wallet related operations to get and update data.
  """

  alias PaymentServer.{Payments, PaymentsRepository}
  alias PaymentServer.Currencies.CurrenciesFormatter

  require Logger

  def create_wallet(%{user_id: user_id, currency: currency, balance: balance} = params, _) do
    with :ok <- Payments.check_if_currency_is_supported(currency),
         :ok <- Payments.check_if_amount_is_positive(balance),
         {:ok, user} <- PaymentsRepository.find_user_by_id(%{id: user_id}),
         :ok <- Payments.check_if_user_already_has_wallet(user, currency) do
      PaymentsRepository.create_wallet(%{
        params
        | balance: CurrenciesFormatter.parse_from_float_to_integer(balance)
      })
    end
  end

  def get_all_wallets(params, _) do
    wallets = PaymentsRepository.list_wallets(params)

    updated_wallets =
      Enum.map(wallets, fn wallet ->
        Map.update!(wallet, :balance, &CurrenciesFormatter.parse_from_integer_to_float/1)
      end)

    {:ok, updated_wallets}
  end

  def transfer_money(
        %{
          origin_user_id: origin_user_id,
          from_currency: from_currency,
          destination_user_id: destination_user_id,
          to_currency: to_currency,
          amount: amount
        },
        _
      ) do
    with :ok <- Payments.check_if_currency_is_supported(from_currency),
         :ok <- Payments.check_if_currency_is_supported(to_currency),
         :ok <- Payments.check_if_amount_is_positive(amount),
         {:ok, origin_user} <- PaymentsRepository.find_user_by_id(%{id: origin_user_id}),
         {:ok, destination_user} <- PaymentsRepository.find_user_by_id(%{id: destination_user_id}),
         {:ok, origin_wallet} <-
           PaymentsRepository.find_wallet_by_user_id(%{user_id: origin_user_id, currency: from_currency}),
         :ok <- Payments.check_if_user_has_enough_balance(origin_wallet, amount),
         {:ok, destination_wallet} <-
           PaymentsRepository.find_wallet_by_user_id(%{
             user_id: destination_user_id,
             currency: to_currency
           }),
          {:ok, [modified_origin_wallet,
                 modified_destination_wallet]} <- Payments.transfer_money(%{
                                                      origin_wallet: origin_wallet,
                                                      destination_wallet: destination_wallet,
                                                      amount: CurrenciesFormatter.parse_from_float_to_integer(amount),
                                                      from_currency: from_currency,
                                                      to_currency: to_currency,
                                                      origin_user: origin_user,
                                                      destination_user: destination_user
                                                    }) do
      #Trigger the subscriptions to notify the change on the users total worth
      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        origin_user,
        total_worth_changed: "user_total_worth_changed:#{origin_user.id}"
      )
      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        destination_user,
        total_worth_changed: "user_total_worth_changed:#{destination_user.id}"
      )
      {:ok, [modified_origin_wallet, modified_destination_wallet]}
    end
  end

  def get_user_wallet(%{user_id: id, currency: currency} = params, _) do
    with :ok <- Payments.check_if_currency_is_supported(currency),
         {:ok, _user} <- PaymentsRepository.find_user_by_id(%{id: id}),
         {:ok, wallet} <- PaymentsRepository.find_wallet_by_user_id(params) do
      {:ok, %{wallet | balance: CurrenciesFormatter.parse_from_integer_to_float(wallet.balance)}}
    end
  end

  def get_total_value_of_all_wallets(%{user_id: id, currency: currency}, _) do
    with :ok <- Payments.check_if_currency_is_supported(currency),
         {:ok, user} <- PaymentsRepository.find_user_by_id(%{id: id}) do
      Payments.get_total_value_of_all_wallets(%{user: user, currency: currency})
    end
  end

end
