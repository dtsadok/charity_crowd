defmodule CharityCrowd.Grants.Nomination do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nominations" do
    field :name, :string
    field :percentage, :integer, default: 0
    field :pitch, :string

    timestamps()
  end

  @doc false
  def changeset(nomination, attrs) do
    nomination
    |> cast(attrs, [:name, :pitch])
    |> validate_required([:name, :pitch])
  end
end
