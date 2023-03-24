defmodule PaymentServerWeb.Types.ExchangeRate do
  use Absinthe.Schema.Notation

  @desc "Information about the exchange rate to be returned in the subscriptions"
  object :exchange_rate do
    field :from_currency, :string
    field :to_currency, :string
    field :value, :float
  end
end
