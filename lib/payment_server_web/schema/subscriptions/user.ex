defmodule PaymentServerWeb.Schema.Subscriptions.User do
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    @desc "Get a notification whenever the total worth of a specific user has changed"
    field :total_worth_changed, :user do
      arg :user_id, non_null :id

      config fn args, _ ->
        {:ok, topic: "user_total_worth_changed:#{args.user_id}"}
      end
    end
  end
end
