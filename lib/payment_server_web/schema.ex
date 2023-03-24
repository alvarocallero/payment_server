defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  import_types PaymentServerWeb.Types.User
  import_types PaymentServerWeb.Types.Wallet
  import_types PaymentServerWeb.Types.ExchangeRate
  import_types PaymentServerWeb.Schema.Queries.User
  import_types PaymentServerWeb.Schema.Queries.Wallet
  import_types PaymentServerWeb.Schema.Mutations.User
  import_types PaymentServerWeb.Schema.Mutations.Wallet
  import_types PaymentServerWeb.Schema.Subscriptions.ExchangeRate
  import_types PaymentServerWeb.Schema.Subscriptions.User

  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    import_fields :exchange_rate_subscriptions
    import_fields :user_subscriptions
  end
end
