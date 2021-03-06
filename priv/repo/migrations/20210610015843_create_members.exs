defmodule CharityCrowd.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :nickname, :string
      add :first, :string
      add :last, :string
      add :email, :string, null: false
      add :password, :string, null: false

      timestamps()
    end
    create unique_index(:members, :nickname)
    create unique_index(:members, :email)
  end
end
