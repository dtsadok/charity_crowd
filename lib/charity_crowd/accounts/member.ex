defmodule CharityCrowd.Accounts.Member do
  use Ecto.Schema
  import Ecto.Changeset
  alias CharityCrowd.Grants.Nomination

  schema "members" do
    has_many :nominations, Nomination

    field :nickname, :string
    field :first, :string
    field :last, :string
    field :email, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:nickname, :first, :last, :email, :password])
    |> validate_required([:nickname, :password])
  end
end
