defmodule PaymentServer.Payments.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :currency, :string
    field :balance, :integer
    belongs_to :user, PaymentServer.Payments.User
  end

  @available_fields [:currency, :balance, :user_id]

  def create_changeset(params) do
    changeset(%PaymentServer.Payments.Wallet{}, params)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
    |> cast_assoc(:user)
  end
end
