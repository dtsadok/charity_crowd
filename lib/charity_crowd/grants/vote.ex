defmodule CharityCrowd.Grants.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  alias CharityCrowd.Accounts.Member
  alias CharityCrowd.Grants.Nomination

  schema "votes" do
    belongs_to :member, Member
    belongs_to :nomination, Nomination
    field :value, VoteValueEnum

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:member_id, :nomination_id, :value])
    |> validate_required([:member_id, :nomination_id, :value])
    |> foreign_key_constraint(:member_id)
    |> foreign_key_constraint(:nomination_id)
    |> unique_constraint([:member_id, :nomination_id])
  end
end
