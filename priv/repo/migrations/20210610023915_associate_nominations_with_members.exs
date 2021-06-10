defmodule CharityCrowd.Repo.Migrations.AssociateNominationsWithMembers do
  use Ecto.Migration

  def change do
    alter table("nominations") do
      add :member_id, references(:members)
    end
  end
end
