defmodule PaymentServerWeb.Schema.Queries.Wallet do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolver

  object :wallet_queries do
    @desc "Get all the wallets from the app"
    field :wallets, list_of :user_wallet do
      resolve &Resolver.Wallet.get_all_wallets/2
    end

    @desc "Get a specific wallet filtering by user_id and currency"
    field :user_wallet, :user_wallet do
      arg :user_id, non_null :id
      arg :currency, non_null :string
      resolve &Resolver.Wallet.get_user_wallet/2
    end

    @desc "Get the total value of all the wallets of a user in a specific currency"
    field :total_value, :float do
      arg :user_id, non_null :id
      arg :currency, non_null :string

      resolve &Resolver.Wallet.get_total_value_of_all_wallets/2
    end
  end
end
