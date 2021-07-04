defmodule CharityCrowd.Repo.Migrations.CreateNominations do
  use Ecto.Migration

  def change do
    create table(:nominations) do
      add :name, :string
      add :pitch, :text
      add :percentage, :float, default: 0

      timestamps()
    end

    create index(:nominations, :name)
    create index(:nominations, :inserted_at)
  end
end
