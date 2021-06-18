defmodule CharityCrowd.Repo.Migrations.CreateInviteCodes do
  use Ecto.Migration

  def change do
    create table(:invite_codes) do
      add :code, :string, null: false
      add :active, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:invite_codes, :code)
  end
end
