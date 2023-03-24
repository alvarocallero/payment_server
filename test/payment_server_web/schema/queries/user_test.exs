defmodule PaymentServerWeb.Schema.Queries.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.PaymentsRepository
  alias PaymentServer.GraphqlHelper

  @get_user_doc """
  query GetUser($id: ID!) {
    user(id: $id){
      #{GraphqlHelper.get_fields_to_fetch_from_user()}
      }
    }
  """

  @get_all_users_doc """
  query GetAllUsers{
    users{
      #{GraphqlHelper.get_fields_to_fetch_from_user()}
      }
    }
  """

  describe "@user" do
    test "fetch a specific user by id" do
      assert {:ok, user} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())

      assert {:ok, %{data: data}} =
               Absinthe.run(@get_user_doc, Schema,
                 variables: %{
                   "id" => user.id
                 }
               )

      assert data["user"]["firstName"] === user.first_name
      assert data["user"]["lastName"] === user.last_name
      assert data["user"]["email"] === user.email
      assert data["user"]["id"] === to_string(user.id)
      assert data["user"]["wallets"] === []
    end
  end

  describe "@users" do
    test "fetch all the users" do
      assert {:ok, user_1} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())
      assert {:ok, user_2} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_2())

      assert {:ok, %{data: data}} = Absinthe.run(@get_all_users_doc, Schema)

      assert Enum.at(data["users"], 0)["firstName"] === user_1.first_name
      assert Enum.at(data["users"], 0)["lastName"] === user_1.last_name
      assert Enum.at(data["users"], 0)["email"] === user_1.email
      assert Enum.at(data["users"], 0)["id"] === to_string(user_1.id)
      assert Enum.at(data["users"], 0)["wallets"] === []

      assert Enum.at(data["users"], 1)["firstName"] === user_2.first_name
      assert Enum.at(data["users"], 1)["lastName"] === user_2.last_name
      assert Enum.at(data["users"], 1)["email"] === user_2.email
      assert Enum.at(data["users"], 1)["id"] === to_string(user_2.id)
      assert Enum.at(data["users"], 1)["wallets"] === []
    end
  end
end
