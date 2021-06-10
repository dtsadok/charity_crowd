defmodule CharityCrowd.Grants.Nomination do
  use Ecto.Schema
  import Ecto.Changeset
  alias CharityCrowd.Accounts.Member

  schema "nominations" do
    belongs_to :member, Member
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
