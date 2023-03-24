defmodule PaymentServerWeb.Schema.Mutations.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema
  alias PaymentServer.PaymentsRepository
  alias PaymentServer.GraphqlHelper

  @create_user_doc """
  mutation CreateUser($email: String!, $first_name: String!, $last_name: String!) {
    create_user(email: $email, first_name: $first_name, last_name: $last_name){
      #{GraphqlHelper.get_fields_to_fetch_from_user()}
      }
    }
  """

  describe "@create_user" do
    test "create a new user" do
      assert {:ok, %{data: data}} =
               Absinthe.run(@create_user_doc, Schema, variables: GraphqlHelper.get_test_user_1())

      assert data["create_user"]["email"] === "mad@max.com.uy"
      assert data["create_user"]["firstName"] === "Mad"
      assert data["create_user"]["lastName"] === "Max"
      assert data["create_user"]["wallets"] === []

      assert {:ok, user} = PaymentsRepository.find_user_by_id(%{id: data["create_user"]["id"]})
      assert user.email === "mad@max.com.uy"
      assert user.first_name === "Mad"
      assert user.last_name === "Max"
      assert user.wallets === []
    end
  end
end
