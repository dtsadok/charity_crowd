#A Ballot is required in order to vote.  Members receive a limited number
#of Ballots per voting period.
defmodule CharityCrowd.Accounts.Ballot do
  use Ecto.Schema
  import Ecto.Changeset
  alias CharityCrowd.Accounts.Member

  schema "ballots" do
    belongs_to :member, Member
    field :date, :date
  end

  @doc false
  def changeset(ballot, attrs) do
    ballot
    |> cast(attrs, [:member_id, :date])
    |> validate_required([:member_id, :date])
    |> foreign_key_constraint(:member_id)
  end
end
