defmodule PaymentServerWeb.Schema.Mutations.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.PaymentsRepository
  alias PaymentServer.GraphqlHelper
  alias PaymentServer.ExchangeRate.ExchangeRateHolder
  alias PaymentServer.ExchangeRate.ExchangeRateMonitor

  @create_wallet_doc """
  mutation CreateWallet($balance: Float!, $currency: String!, $user_id: ID!) {
    create_wallet(balance: $balance, currency: $currency, user_id: $user_id){
      #{GraphqlHelper.get_fields_to_fetch_from_wallet()}
      }
    }
  """

  @transfer_money_doc """
  mutation TransferMoney($origin_user_id: ID!, $from_currency: String!, $destination_user_id: ID!, $to_currency: String!, $amount: Float!) {
    transfer_money(origin_user_id: $origin_user_id, from_currency: $from_currency, destination_user_id: $destination_user_id, to_currency: $to_currency, amount: $amount){
      #{GraphqlHelper.get_fields_to_fetch_from_wallet()}
      }
    }
  """

  describe "@create_wallet" do
    test "create a wallet with success" do
      assert {:ok, user} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())

      assert {:ok, %{data: data}} =
               Absinthe.run(@create_wallet_doc, Schema,
                 variables: GraphqlHelper.get_test_wallet(1500.50, "USD", user.id)
               )

      assert data["create_wallet"]["currency"] === "USD"

      assert {:ok, user} = PaymentsRepository.find_user_by_id(%{id: user.id})
      assert user.email === "mad@max.com.uy"
      assert user.first_name === "Mad"
      assert user.last_name === "Max"
      assert hd(user.wallets).balance === 150_050
      assert hd(user.wallets).currency === "USD"
    end

    test "create a wallet with an unsupported currency" do
      assert {:ok, user} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())

      {:ok, msg} =
        Absinthe.run(@create_wallet_doc, Schema,
          variables: GraphqlHelper.get_test_wallet(1500.50, "ARS", user.id)
        )

      assert hd(msg.errors).message == "Error, the currency ARS is not supported"
    end

    test "create a wallet with a non-existent user" do
      {:ok, msg} =
        Absinthe.run(@create_wallet_doc, Schema,
          variables: GraphqlHelper.get_test_wallet(1500.50, "USD", 69)
        )

      assert hd(msg.errors).message == "Error, user not found with id 69"
    end
  end

  describe "@transfer_money" do
    test "transfer money between 2 wallets in the same currency with success" do
      assert {:ok, user_1} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())
      assert {:ok, user_2} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_2())

      assert {:ok, _wallet_1} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(150_050, "USD", user_1.id))

      assert {:ok, _wallet_2} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(10_055, "USD", user_2.id))

      assert {:ok, %{data: _data}} =
               Absinthe.run(@transfer_money_doc, Schema,
                 variables:
                   GraphqlHelper.get_test_transfer_money(
                     user_1.id,
                     "USD",
                     user_2.id,
                     "USD",
                     100.00
                   )
               )

      assert {:ok, updated_wallet_user_1} =
               PaymentsRepository.find_wallet_by_user_id(%{user_id: user_1.id, currency: "USD"})

      assert {:ok, updated_wallet_user_2} =
               PaymentsRepository.find_wallet_by_user_id(%{user_id: user_2.id, currency: "USD"})

      assert updated_wallet_user_1.balance == 140_050
      assert updated_wallet_user_2.balance == 20_055
    end

    test "transfer money between 2 wallets in different currencies with success" do
      {_, pid} = ExchangeRateMonitor.get_pid_of_exchange_rate_process("EUR", "UYU")
      ExchangeRateHolder.update_exchange_rate(pid, 3965)
      assert {:ok, user_1} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())
      assert {:ok, user_2} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_2())

      assert {:ok, wallet_1} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(150_050, "EUR", user_1.id))

      assert {:ok, wallet_2} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(10_055, "UYU", user_2.id))

      assert {:ok, %{data: _data}} =
               Absinthe.run(@transfer_money_doc, Schema,
                 variables:
                   GraphqlHelper.get_test_transfer_money(
                     user_1.id,
                     "EUR",
                     user_2.id,
                     "UYU",
                     100
                   )
               )

      assert {:ok, updated_wallet_user_1} =
               PaymentsRepository.find_wallet_by_user_id(%{user_id: user_1.id, currency: "EUR"})

      assert {:ok, updated_wallet_user_2} =
               PaymentsRepository.find_wallet_by_user_id(%{user_id: user_2.id, currency: "UYU"})

      assert wallet_1.balance < updated_wallet_user_1.balance
      assert updated_wallet_user_2.balance > wallet_2.balance
    end

    test "transfer money between wallets with unsupported currencies" do
      {:ok, msg} =
        Absinthe.run(@transfer_money_doc, Schema,
          variables: GraphqlHelper.get_test_transfer_money(1, "ARS", 2, "ARS", 100.00)
        )

      assert hd(msg.errors).message == "Error, the currency ARS is not supported"
    end

    test "transfer money without enough balance" do
      assert {:ok, user_1} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())
      assert {:ok, user_2} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_2())

      assert {:ok, _wallet_1} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(1, "USD", user_1.id))

      assert {:ok, _wallet_2} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(10_055, "UYU", user_2.id))

      {:ok, msg} =
        Absinthe.run(@transfer_money_doc, Schema,
          variables:
            GraphqlHelper.get_test_transfer_money(user_1.id, "USD", user_2.id, "UYU", 10_000.00)
        )

      assert hd(msg.errors).message ==
               "Error, the user does not have enough balance to make the transfer | transfer_amount: 10000.00"
    end

    test "transfer money between non-existent users" do
      {:ok, msg} =
        Absinthe.run(@transfer_money_doc, Schema,
          variables: GraphqlHelper.get_test_transfer_money(1, "USD", 2, "USD", 100.00)
        )

      assert hd(msg.errors).message == "Error, user not found with id 1"
    end
  end
end
