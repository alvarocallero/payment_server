defmodule PaymentServerWeb.Schema.Queries.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.PaymentsRepository
  alias PaymentServer.GraphqlHelper

  @get_all_wallets_doc """
  query GetAllWallets{
    wallets{
      #{GraphqlHelper.get_fields_to_fetch_from_wallet()}
      }
    }
  """

  @get_wallet_doc """
  query GetWallet($user_id: ID!, $currency: String!) {
    user_wallet(user_id: $user_id, currency: $currency){
      #{GraphqlHelper.get_fields_to_fetch_from_wallet()}
      }
    }
  """

  @get_total_worth_doc """
  query GetTotalWorth($user_id: ID!, $currency: String!) {
    total_value(user_id: $user_id, currency: $currency)
    }
  """

  describe "@wallets" do
    test "fetch all the wallets" do
      assert {:ok, user_1} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())
      assert {:ok, user_2} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_2())

      assert {:ok, _wallet_1} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(15_050, "USD", user_1.id))

      assert {:ok, _wallet_2} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(25_075, "USD", user_2.id))

      assert {:ok, _wallet_3} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(1_000_050, "UYU", user_1.id))

      assert {:ok, _wallet_4} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(7500, "UYU", user_2.id))

      assert {:ok, %{data: data}} = Absinthe.run(@get_all_wallets_doc, Schema)
      assert Enum.at(data["wallets"], 0)["balance"] === 150.5
      assert Enum.at(data["wallets"], 0)["currency"] === "USD"
      assert Enum.at(data["wallets"], 1)["balance"] === 250.75
      assert Enum.at(data["wallets"], 1)["currency"] === "USD"
      assert Enum.at(data["wallets"], 2)["balance"] === 10_000.5
      assert Enum.at(data["wallets"], 2)["currency"] === "UYU"
      assert Enum.at(data["wallets"], 3)["balance"] === 75.00
      assert Enum.at(data["wallets"], 3)["currency"] === "UYU"
    end
  end

  describe "@user_wallet" do
    test "fetch a wallet by user_id and currency" do
      assert {:ok, user} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())

      assert {:ok, wallet} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(15_050, "USD", user.id))

      assert {:ok, %{data: data}} =
               Absinthe.run(@get_wallet_doc, Schema,
                 variables: %{
                   "user_id" => user.id,
                   "currency" => wallet.currency
                 }
               )

      assert data["user_wallet"]["balance"] === 150.50
      assert data["user_wallet"]["currency"] === "USD"
    end
  end

  describe "@total_value" do
    test "fetch the total value of all the user wallets in a single currency" do
      assert {:ok, user} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())

      assert {:ok, _wallet} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(15_050, "USD", user.id))

      assert {:ok, _wallet} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(1000, "USD", user.id))

      assert {:ok, _wallet} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(5000, "USD", user.id))

      assert {:ok, %{data: data}} =
               Absinthe.run(@get_total_worth_doc, Schema,
                 variables: %{
                   "user_id" => user.id,
                   "currency" => "USD"
                 }
               )

      assert data["total_value"] === 210.5
    end
  end
end
