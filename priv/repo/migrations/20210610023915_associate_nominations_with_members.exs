defmodule CharityCrowd.Repo.Migrations.AssociateNominationsWithMembers do
  use Ecto.Migration

  def change do
    alter table("nominations") do
      add :member_id, references(:members), null: false
    end
    create index(:nominations, :member_id)
  end
end
