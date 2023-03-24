defmodule PaymentServerWeb.Types.Wallet do
  use Absinthe.Schema.Notation

  @desc "Information about the wallets"
  object :user_wallet do
    field :id, :id
    field :balance, :float
    field :currency, :string
  end
end
