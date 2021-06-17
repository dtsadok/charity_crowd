defmodule CharityCrowd.Grants.Vote do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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
    |> prepare_changes(fn changeset ->
         if nomination_id = get_change(changeset, :nomination_id) do
           query = from Nomination, where: [id: ^nomination_id]

           case get_change(changeset, :value) do
             :Y -> changeset.repo.update_all(query, inc: [yes_vote_count: 1])
             :N -> changeset.repo.update_all(query, inc: [no_vote_count: 1])
           end
         end
         changeset
     end)

  end
end
