defmodule CharityCrowd.Repo.Migrations.AddVoteCountsToNomination do
  use Ecto.Migration

  def change do
    alter table("nominations") do
      add :yes_vote_count, :integer, default: 0, null: false
      add :no_vote_count, :integer, default: 0, null: false
    end
  end
end
