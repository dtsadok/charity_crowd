defmodule CharityCrowd.Grants.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  alias CharityCrowd.Grants.Nomination

  schema "votes" do
    belongs_to :nomination, Nomination
    field :value, VoteValueEnum

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:nomination_id, :value])
    |> validate_required([:nomination_id, :value])
    |> foreign_key_constraint(:nomination_id)
  end
end
