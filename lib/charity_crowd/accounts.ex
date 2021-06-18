defmodule CharityCrowd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias CharityCrowd.Repo

  alias CharityCrowd.Accounts.Member
  alias CharityCrowd.Grants.Nomination

  @doc """
  Returns the list of members.

  ## Examples

      iex> list_members()
      [%Member{}, ...]

  """
  def list_members do
    Repo.all(Member)
      |> Repo.preload(nominations: :nomination)
  end

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id) do
    Repo.get!(Member, id)
      |> Repo.preload(:nominations)
  end

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:nominations, with: &Nomination.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{data: %Member{}}

  """
  def change_member(%Member{} = member, attrs \\ %{}) do
    Member.changeset(member, attrs)
  end

  def authenticate(email, password) do
    query =
      from m in Member,
        where: m.email == ^email

    case Repo.one(query) do
      %Member{} = member ->
        if Argon2.verify_pass(password, member.password) do
          {:ok, member}
        else
          {:error, :invalid_credentials}
        end

      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  alias CharityCrowd.Accounts.InviteCode

  @doc """
  Returns the list of invite_codes.

  ## Examples

      iex> list_invite_codes()
      [%InviteCode{}, ...]

  """
  def list_invite_codes do
    Repo.all(InviteCode)
  end

  @doc """
  Gets a single invite_code.

  Raises `Ecto.NoResultsError` if the Invite code does not exist.

  ## Examples

      iex> get_active_invite_code!("AAAA")
      %InviteCode{}

      iex> get_active_invite_code!("BBBB")
      ** (Ecto.NoResultsError)

  """
  def get_active_invite_code!(code) do
    query =
      from i in InviteCode,
        where: i.code == ^code and i.active == true

    Repo.one!(query)
  end

  @doc """
  Creates a invite_code.

  ## Examples

      iex> create_invite_code(%{field: value})
      {:ok, %InviteCode{}}

      iex> create_invite_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite_code(attrs \\ %{}) do
    %InviteCode{}
    |> InviteCode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invite_code.

  ## Examples

      iex> update_invite_code(invite_code, %{field: new_value})
      {:ok, %InviteCode{}}

      iex> update_invite_code(invite_code, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite_code(%InviteCode{} = invite_code, attrs) do
    invite_code
    |> InviteCode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invite_code.

  ## Examples

      iex> delete_invite_code(invite_code)
      {:ok, %InviteCode{}}

      iex> delete_invite_code(invite_code)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite_code(%InviteCode{} = invite_code) do
    Repo.delete(invite_code)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invite_code changes.

  ## Examples

      iex> change_invite_code(invite_code)
      %Ecto.Changeset{data: %InviteCode{}}

  """
  def change_invite_code(%InviteCode{} = invite_code, attrs \\ %{}) do
    InviteCode.changeset(invite_code, attrs)
  end
end
