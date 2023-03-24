defmodule PaymentServer.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :currency, :text
      add :balance, :integer
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:wallets, [:user_id])
  end

end

