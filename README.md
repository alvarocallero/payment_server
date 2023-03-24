![ScreenShot](https://github.com/alvarocallero/payment_server/blob/master/payment_server.png)

# Payment Server
PaymentServer allows sending money between users in different currencies. 
All the operations were built using GraphQL mutations, queries, and subscriptions, such as create users and wallets, transfer money and receive notifications whenever some event occur.
The exchange rate server was built using OTP features like Agents, GenServer and Supervisors, that will store the exchange rate between a pair of currencies and will be in a loop calling the AlphaVantage API to get the last exchange rate.

The functionality in terms of GraphQL queries is the following:
1) Fetch Users: get all the users of the app.
2) Fetch User: get a specific user of the app, filtering by user id.
3) Fetch Wallets: get all the wallets of the app.
4) Fetch Wallet: get a specific wallet filtering by user id and currency
5) Total Value: Get the total value of all the wallets of a user in a specific currency.

The functionality in terms of GraphQL mutations is the following:
1) Create User: create a new user in the app without a wallet.
2) Create Wallet: create a wallet for a specific currency with a given currency and balance.
3) Transfer Money: transfer money between 2 wallets. The transfer can be in the same currency, or with different currencies, in which case the exchange rate between those currencies is applied.

The functionality in terms of GraphQL subscriptions is the following:
1) Exchange Rate Changed: Get a notification whenever the exchange rate of a specific currency has changed.
2) All Exchange Rate Changed: Get a notification whenever all the exchange rate changes.
3) Total Worth Changed: Get a notification whenever the total worth of a specific user has changed

# Starting Payment Server


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `ecto.create` and `mix ecto.migrate` 
  * Start an AlphaVantage local server, in case we don´t want to call the real AlphaVantage API.
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Use some GraphQL client at http://localhost:4000/



## Extra info

  * AlphaVantage API: https://www.alphavantage.co/documentation/#currency-exchange
