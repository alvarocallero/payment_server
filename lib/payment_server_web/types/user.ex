defmodule PaymentServerWeb.Types.User do
  use Absinthe.Schema.Notation

  @desc "Information about the users"
  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :wallets, list_of :user_wallet
  end
end
