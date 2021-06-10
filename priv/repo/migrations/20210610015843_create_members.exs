defmodule CharityCrowd.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :nickname, :string
      add :first, :string
      add :last, :string
      add :email, :string
      add :password, :string

      timestamps()
    end
    create index(:members, [:nickname])
  end
end
