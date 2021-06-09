defmodule CharityCrowd.Nomination do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nominations" do
    field :name, :string
    field :pitch, :string
    field :percentage, :integer

    timestamps()
  end

  @doc false
  def changeset(nomination, attrs) do
    nomination
    |> cast(attrs, [:name, :pitch, :percentage])
    |> validate_required([:name, :pitch])
  end
end
