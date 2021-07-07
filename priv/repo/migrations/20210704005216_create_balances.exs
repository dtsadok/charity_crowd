defmodule CharityCrowd.Repo.Migrations.CreateBalances do
  use Ecto.Migration

  def change do
    create table(:balances) do
      add :amount_cents, :integer
      add :date, :date

      timestamps()
    end

    create index(:balances, :date)
  end
end
