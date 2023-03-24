defmodule PaymentServer.PaymentsRepository do
  @moduledoc """
  This module contains the logic for the communication with EctoShorts, providing update/create/retrieve operations
  for User and Wallet schemas.
  Despite the fact the balance of the wallets are stored as integer, this value is shown as float on the GraphQL operations.
  """

  alias EctoShorts.Actions
  alias PaymentServer.Payments.{Wallet, User}
  alias PaymentServer.Currencies.CurrenciesFormatter
  alias PaymentServer.ErrorHandling

  require Logger

  # User related operations

  def find_user_by_id(%{id: id} = params) do
    case Actions.find(User, %{id: id, preload: [:wallets]}) do
      {:ok, user} ->
        {:ok, user}

      error ->
        ErrorHandling.build_error_response(error, params, "find_user_by_id")
    end
  end

  def create_user(params) do
    case Actions.create(User, params) do
      {:ok, user} ->
        {:ok, %{user | wallets: []}}

      error ->
        ErrorHandling.build_error_response(error, params, "create_user")
    end
  end

  def get_all_users(params \\ %{}) do
    Actions.all(User, %{params: params, preload: [:wallets]})
  end

  # Wallet related operations

  def create_wallet(params) do
    case Actions.create(Wallet, params) do
      {:ok, wallet} ->
        {:ok,
         %{wallet | balance: CurrenciesFormatter.parse_from_integer_to_float(wallet.balance)}}

      error ->
        ErrorHandling.build_error_response(error, params, "create_wallet")
    end
  end

  def list_wallets(params \\ %{}) do
    Actions.all(Wallet, params)
  end

  def update_wallet(%{id: id} = params) do
    case Actions.update(Wallet, id, params) do
      {:ok, wallet} ->
        {:ok, wallet}

      error ->
        ErrorHandling.build_error_response(error, params, "update_wallet")
    end
  end

  def find_wallet_by_user_id(%{user_id: user_id, currency: currency} = params) do
    case Actions.find(Wallet, %{user_id: user_id, currency: currency}) do
      {:ok, wallet} ->
        {:ok, wallet}

      error ->
        ErrorHandling.build_error_response(error, params, "find_wallet_by_user_id")
    end
  end

end
