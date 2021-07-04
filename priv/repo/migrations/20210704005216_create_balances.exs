defmodule CharityCrowd.Repo.Migrations.CreateBalances do
  use Ecto.Migration

  def change do
    create table(:balances) do
      add :amount_cents, :integer

      timestamps()
    end

    create index(:balances, :inserted_at)
  end
end
