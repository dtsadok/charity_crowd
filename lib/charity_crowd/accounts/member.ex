defmodule CharityCrowd.Accounts.Member do
  use Ecto.Schema
  import Ecto.Changeset
  alias CharityCrowd.Grants.Nomination
  alias Argon2

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
    |> validate_required([:nickname, :email, :password])
    |> unique_constraint([:nickname, :email])
    |> put_password_hash()
   end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
