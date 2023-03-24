defmodule PaymentServerWeb.Schema.Subscription.ExchangeRateTest do
  use PaymentServer.SubscriptionCase

  alias PaymentServer.GraphqlHelper

  @exchange_rate_updated_sub_doc """
  subscription ExchangeRateUpdated($currency: String!){
    exchange_rate_changed(currency: $currency){
      #{GraphqlHelper.get_fields_to_fetch_from_exchange_rate_subscription()}
      }
    }
  """

  @all_exchange_rates_updated_sub_doc """
  subscription AllExchangeRatesUpdated{
    all_exchange_rates_changed
    }
  """

  describe "@exchange_rate_changed" do
    test "sends a notification whenever the exchange rate for a specific currency changes", %{
      socket: socket
    } do
      ref = push_doc(socket, @exchange_rate_updated_sub_doc, variables: %{currency: "USD"})

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      subscription_payload = %{
        from_currency: "USD",
        to_currency: "UYU",
        value: 38.45
      }

      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        subscription_payload,
        exchange_rate_changed: "exchange_rate_changed:USD"
      )

      assert_receive %{
        event: "subscription:data",
        join_ref: nil,
        payload: %{
          result: %{
            data: %{
              "exchange_rate_changed" => %{
                "from_currency" => "USD",
                "to_currency" => "UYU",
                "value" => 38.45
              }
            }
          },
          subscriptionId: ^subscription_id
        },
        ref: nil
      }
    end
  end

  describe "@all_exchange_rates_changed" do
    test "sends a notification when all the exchange rate changes", %{
      socket: socket
    } do
      ref = push_doc(socket, @all_exchange_rates_updated_sub_doc)

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      Absinthe.Subscription.publish(
        PaymentServerWeb.Endpoint,
        "all_exchange_rates_changed",
        all_exchange_rates_changed: "all_exchange_rates_changed"
      )

      assert_receive %{
        event: "subscription:data",
        join_ref: nil,
        payload: %{
          result: %{
            data: %{
              "all_exchange_rates_changed" => "all_exchange_rates_changed"
            }
          },
          subscriptionId: ^subscription_id
        },
        ref: nil
      }
    end
  end
end
