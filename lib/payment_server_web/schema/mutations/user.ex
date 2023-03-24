defmodule PaymentServerWeb.Schema.Mutations.User do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolver

  object :user_mutations do
    @desc "Create a new user in the system"
    field :create_user, :user do
      arg :email, non_null :string
      arg :first_name, non_null :string
      arg :last_name, non_null :string

      resolve &Resolver.User.create_user/2
    end
  end
end
