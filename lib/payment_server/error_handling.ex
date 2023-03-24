defmodule PaymentServer.ErrorHandling do
  @moduledoc """
  Provides a common module for creating error responses for every error situation that the app can handle.
  """
  require Logger

  defp get_error_msg_user_not_found(id), do: "Error, user not found with id #{id}"

  defp get_error_msg_creating_user(reason),
    do: "Error trying to create a user | reason: #{reason}"

  defp get_error_msg_creating_wallet(reason),
    do: "Error trying to create a wallet | reason: #{reason}"

  defp get_error_msg_updating_wallet(id, reason),
    do: "Error, error trying to update the wallet with id #{id} | reason: #{reason}"

  defp get_error_msg_wallet_not_found(user_id, currency),
    do: "Error, wallet not found for user_id #{user_id} and currency: #{currency}"

  defp get_error_msg_currency_not_supported(currency),
    do: "Error, the currency #{currency} is not supported"

  defp get_error_msg_insufficient_funds(transfer_amount),
    do:
      "Error, the user does not have enough balance to make the transfer | transfer_amount: #{transfer_amount}"

  defp get_error_msg_negative_amount(amount),
    do: "Error, the amount must be positive | amount: #{amount}"

  defp get_error_msg_calling_api(reason),
    do: "An error occurred trying to parse the API response | reason: #{reason}"

  defp get_error_msg_user_already_has_wallet(id, currency),
    do: "Error, the user with id #{id} already has a wallet with currency #{currency}"

  defp get_error_msg_api_call_failed(reason),
    do: "Error, the call to AlphaVantage API failed | reason: #{reason}"

  def build_error_response({:error, _msg}, %{id: id} = params, "find_user_by_id") do
    Logger.error(get_error_msg_user_not_found(id))
    {:error, %{message: get_error_msg_user_not_found(id), details: params}}
  end

  def build_error_response({:error, msg}, params, "create_user") do
    Logger.error(get_error_msg_creating_user(inspect(msg.errors)))

    {:error, %{message: get_error_msg_creating_user(inspect(msg.errors)), details: params}}
  end

  def build_error_response({:error, msg}, params, "create_wallet") do
    Logger.error(get_error_msg_creating_wallet(inspect(msg.errors)))
    {:error, %{message: get_error_msg_creating_wallet(inspect(msg.errors)), details: params}}
  end

  def build_error_response({:error, msg}, %{id: id} = params, "update_wallet") do
    Logger.error(get_error_msg_updating_wallet(id, inspect(msg.errors)))
    {:error, %{message: get_error_msg_updating_wallet(id, inspect(msg.errors)), details: params}}
  end

  def build_error_response(
        {:error, _msg},
        %{user_id: user_id, currency: currency} = params,
        "find_wallet_by_user_id"
      ) do
    Logger.error(get_error_msg_wallet_not_found(user_id, currency))
    {:error, %{message: get_error_msg_wallet_not_found(user_id, currency), details: params}}
  end

  def build_error_response(currency, "check_if_currency_is_supported") do
    Logger.error(get_error_msg_currency_not_supported(currency))

    {:error,
     %{
       message: get_error_msg_currency_not_supported(currency),
       details: "currency: #{currency}"
     }}
  end

  def build_error_response(transfer_amount, "check_if_user_has_enough_balance") do
    Logger.error(get_error_msg_insufficient_funds(transfer_amount))

    {:error,
     %{
       message: get_error_msg_insufficient_funds(transfer_amount),
       details: "transfer_amount: #{transfer_amount}"
     }}
  end

  def build_error_response(amount, "check_if_amount_is_positive") do
    Logger.error(get_error_msg_negative_amount(amount))

    {:error,
     %{
       message: get_error_msg_negative_amount(amount),
       details: "amount: #{amount}"
     }}
  end

  def build_error_response(reason, "parse_api_response") do
    Logger.error(get_error_msg_calling_api(reason))
    {:error, reason}
  end

  def build_error_response(%{user_id: id, currency: currency}, "check_if_user_already_has_wallet") do
    Logger.error(get_error_msg_user_already_has_wallet(id, currency))

    {:error,
     %{
       message: get_error_msg_user_already_has_wallet(id, currency),
       details: "id: #{id} | currency: #{currency}"
     }}
  end

  def build_error_response(reason, "make_http_get_request") do
    Logger.error(get_error_msg_api_call_failed(reason))

    {:error,
     %{
       message: get_error_msg_api_call_failed(reason),
       details: "API call failed"
     }}
  end
end
