defmodule PaymentServerWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolver

  object :user_queries do
    @desc "Get a user filtering by the id"
    field :user, :user do
      arg :id, non_null :id
      resolve &Resolver.User.find_by_id/2
    end

    @desc "Return all the users of the system"
    field :users, list_of :user do
      resolve &Resolver.User.get_all_users/2
    end
  end
end
