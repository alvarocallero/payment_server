defmodule PaymentServerWeb.Schema.Subscriptions.ExchangeRate do
  use Absinthe.Schema.Notation

  object :exchange_rate_subscriptions do
    @desc "Get a notification whenever the exchange rate of a specific currency has changed."
    field :exchange_rate_changed, :exchange_rate do
      arg :currency, non_null :string

      config fn args, _ ->
        {:ok, topic: "exchange_rate_changed:#{args.currency}"}
      end
    end

    @desc "Get a notification whenever all the exchange rate changes."
    field :all_exchange_rates_changed, :string do
      config fn _, _ ->
        {:ok, topic: "all_exchange_rates_changed"}
      end
    end
  end
end
