defmodule CharityCrowd.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    VoteValueEnum.create_type

    create table(:votes) do
      add :nomination_id, :integer, null: false
      add :value, VoteValueEnum.type(), null: false

      timestamps()
    end

    create index(:votes, :nomination_id)
  end
end
