defmodule CharityCrowd.Grants do
  @moduledoc """
  The Grants context.
  """

  import Ecto.Query, warn: false
  alias CharityCrowd.Repo

  alias CharityCrowd.Grants.Nomination
  alias CharityCrowd.Grants.Vote

  @doc """
  Returns the list of nominations.

  ## Examples

      iex> list_nominations(month, year)
      [%Nomination{}, ...]

  """
  def list_nominations(month, year) do
    {start_datetime, end_datetime} = start_end_from(month, year)

    query = from n in Nomination,
              where: n.inserted_at >= ^start_datetime and n.inserted_at < ^end_datetime

    Repo.all(query)
      |> Repo.preload([:member, :votes])
  end

  def list_nominations_with_votes_by(member, month, year) do
    {start_datetime, end_datetime} = start_end_from(month, year)

    query = from nom in Nomination,
              left_join: v in Vote,
              on: v.nomination_id == nom.id,
              select: %{id: nom.id, name: nom.name, pitch: nom.pitch, percentage: nom.percentage, yes_vote_count: nom.yes_vote_count, no_vote_count: nom.no_vote_count, vote_value: v.value},
              where: v.member_id == ^member.id and nom.inserted_at >= ^start_datetime and nom.inserted_at < ^end_datetime

    Repo.all(query)
      #|> Repo.preload([:member, :votes])
  end

  @doc """
  Gets a single nomination.

  Raises `Ecto.NoResultsError` if the Nomination does not exist.

  ## Examples

      iex> get_nomination!(123)
      %Nomination{}

      iex> get_nomination!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nomination!(id) do
    Repo.get!(Nomination, id)
      |> Repo.preload([:member, :votes])
  end

  @doc """
  Creates a nomination.

  ## Examples

      iex> create_nomination(%{field: value})
      {:ok, %Nomination{}}

      iex> create_nomination(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nomination(attrs \\ %{}) do
    %Nomination{}
    |> Nomination.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a nomination.

  ## Examples

      iex> update_nomination(nomination, %{field: new_value})
      {:ok, %Nomination{}}

      iex> update_nomination(nomination, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_nomination(%Nomination{} = nomination, attrs) do
    nomination
    |> Nomination.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a nomination.

  ## Examples

      iex> delete_nomination(nomination)
      {:ok, %Nomination{}}

      iex> delete_nomination(nomination)
      {:error, %Ecto.Changeset{}}

  """
  def delete_nomination(%Nomination{} = nomination) do
    Repo.delete(nomination)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking nomination changes.

  ## Examples

      iex> change_nomination(nomination)
      %Ecto.Changeset{data: %Nomination{}}

  """
  def change_nomination(%Nomination{} = nomination, attrs \\ %{}) do
    Nomination.changeset(nomination, attrs)
  end

  alias CharityCrowd.Grants.Vote

  @doc """
  Returns the list of votes.

  ## Examples

      iex> list_votes()
      [%Vote{}, ...]

  """
  def list_votes do
    Repo.all(Vote)
      |> Repo.preload([:member, :nomination])
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id) do
    Repo.get!(Vote, id)
      |> Repo.preload([:member, :nomination])
  end

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(attrs \\ %{}) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  defp start_end_from(month, year) do
    {:ok, start_date} = Date.new(year, month, 1)
    days = Date.days_in_month(start_date)
    #calculate first of next month
    end_date = Date.add(start_date, days+1)
    #TODO: Globalize
    tz = "America/New_York"
    start_datetime = Calendar.DateTime.from_date_and_time_and_zone!(start_date, ~T[00:00:00], tz)
    end_datetime = Calendar.DateTime.from_date_and_time_and_zone!(end_date, ~T[00:00:00], tz)

    {start_datetime, end_datetime}
  end
end
