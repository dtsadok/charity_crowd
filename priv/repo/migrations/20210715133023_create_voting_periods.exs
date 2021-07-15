defmodule CharityCrowd.Repo.Migrations.CreateVotingPeriods do
  use Ecto.Migration

  def change do
    create table(:voting_periods) do
      add :start_date, :date, null: false
    end

    create index(:voting_periods, :start_date)
  end
end
