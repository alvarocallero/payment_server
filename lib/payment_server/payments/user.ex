defmodule PaymentServer.Payments.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    has_many :wallets, PaymentServer.Payments.Wallet
  end

  @available_fields [:email, :first_name, :last_name]

  def create_changeset(params) do
    changeset(%PaymentServer.Payments.User{}, params)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @available_fields)
    |> validate_required(@available_fields)
    |> unique_constraint(:email, message: "the email already belongs to a user")
    |> cast_assoc(:wallets)
  end
end
