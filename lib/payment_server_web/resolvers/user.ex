defmodule PaymentServerWeb.Resolver.User do
  @doc """
  Provides all the User related operations to get and update data.
  """

  alias PaymentServer.PaymentsRepository
  alias PaymentServer.Currencies.CurrenciesFormatter

  def find_by_id(%{id: id}, _) do
    id = String.to_integer(id)

    case PaymentsRepository.find_user_by_id(%{id: id}) do
      {:ok, user} ->
        updated_wallets = parse_wallet_balance_to_float(user.wallets)

        {:ok, Map.replace(user, :wallets, updated_wallets)}

      error ->
        error
    end
  end

  def create_user(params, _) do
    PaymentsRepository.create_user(params)
  end

  def get_all_users(params, _) do
    users = PaymentsRepository.get_all_users(params)

    updated_users =
      Enum.map(users, fn user ->
        %{user | wallets: parse_wallet_balance_to_float(user.wallets)}
      end)

    {:ok, updated_users}
  end

  defp parse_wallet_balance_to_float(wallets) do
    Enum.map(wallets, fn wallet ->
      Map.update!(wallet, :balance, &CurrenciesFormatter.parse_from_integer_to_float/1)
    end)
  end
end
