defmodule CharityCrowd.Repo.Migrations.CreateBallots do
  use Ecto.Migration

  def change do
    create table(:ballots) do
      add :member_id, :integer, null: false
      add :date, :date, null: false
    end

    create index(:ballots, [:member_id, :date])
  end
end
