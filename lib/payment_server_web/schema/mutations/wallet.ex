defmodule PaymentServerWeb.Schema.Mutations.Wallet do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolver

  object :wallet_mutations do
    @desc "Create a new wallet in the system"
    field :create_wallet, :user_wallet do
      arg :balance, non_null  :float
      arg :currency, non_null :string
      arg :user_id, non_null :id

      resolve &Resolver.Wallet.create_wallet/2
    end

    @desc "Send money between 2 users"
    field :transfer_money, list_of :user_wallet do
      arg :origin_user_id, non_null :id
      arg :from_currency, non_null :string
      arg :destination_user_id, non_null :id
      arg :to_currency, non_null :string
      arg :amount, non_null :float

      resolve &Resolver.Wallet.transfer_money/2
    end
  end
end
