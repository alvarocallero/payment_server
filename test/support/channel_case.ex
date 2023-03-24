defmodule PaymentServer.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest

      @endpoint PaymentServerWeb.Endpoint
    end
  end
end
