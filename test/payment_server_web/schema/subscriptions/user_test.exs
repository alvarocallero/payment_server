defmodule PaymentServerWeb.Schema.Subscriptions.UserTest do
  use PaymentServer.SubscriptionCase
  use PaymentServer.DataCase, async: true

  alias PaymentServer.GraphqlHelper
  alias PaymentServer.PaymentsRepository

  @total_worth_changed_sub_doc """
  subscription TotalWorthChanged($user_id: ID!){
    total_worth_changed(user_id: $user_id){
      #{GraphqlHelper.get_fields_to_fetch_from_user()}
      }
    }
  """

  describe "@total_worth_changed" do
    test "sends a notification whenever the total worth of a specific user goes up or down", %{
      socket: socket
    } do
      assert {:ok, user} = PaymentsRepository.create_user(GraphqlHelper.get_test_user_1())

      assert {:ok, _wallet} =
               PaymentsRepository.create_wallet(GraphqlHelper.get_test_wallet(15_050, "USD", user.id))

      ref = push_doc(socket, @total_worth_changed_sub_doc, variables: %{user_id: user.id})

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        user,
        total_worth_changed: "user_total_worth_changed:#{user.id}"
      )

      assert_receive %{
        event: "subscription:data",
        join_ref: nil,
        payload: %{
          result: %{
            data: %{
              "total_worth_changed" => %{
                "firstName" => "Mad",
                "lastName" => "Max",
                "email" => "mad@max.com.uy"
              }
            }
          },
          subscriptionId: ^subscription_id
        },
        ref: nil
      }
    end
  end
end
