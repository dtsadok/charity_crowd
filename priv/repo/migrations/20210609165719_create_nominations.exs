defmodule CharityCrowd.Repo.Migrations.CreateNominations do
  use Ecto.Migration

  def change do
    create table(:nominations) do
      add :name, :string
      add :pitch, :text
      add :percentage, :integer, default: 0

      timestamps()
    end

  end
end
