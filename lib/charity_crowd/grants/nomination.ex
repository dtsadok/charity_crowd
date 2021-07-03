defmodule CharityCrowd.Grants.Nomination do
  use Ecto.Schema
  import Ecto.Changeset
  alias CharityCrowd.Accounts.Member
  alias CharityCrowd.Grants.Vote

  schema "nominations" do
    belongs_to :member, Member
    has_many :votes, Vote
    field :name, :string
    field :percentage, :integer, default: 0
    field :pitch, :string

    timestamps()
  end

  @doc false
  def changeset(nomination, attrs) do
    nomination
    |> cast(attrs, [:member_id, :name, :pitch])
    |> validate_required([:member_id, :name, :pitch])
    |> foreign_key_constraint(:member_id)
  end
end
