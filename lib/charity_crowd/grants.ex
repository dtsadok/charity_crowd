defmodule CharityCrowd.Grants do
  @moduledoc """
  The Grants context.
  """

  import Ecto.Query, warn: false
  alias CharityCrowd.Repo

  alias CharityCrowd.Grants.Nomination
  alias CharityCrowd.Grants.Vote
  alias CharityCrowd.Endowment

  #inspired by https://medium.com/@eric.programmer/the-sql-alternative-to-counter-caches-59e2098b7d7
  def vote_count_subquery do
    from v in Vote,
      select: %{
        nomination_id: v.nomination_id,
        vote_count: count(v.id)
      },
      group_by: v.nomination_id
  end

  def yes_vote_count_subquery do
    from v in vote_count_subquery(), where: v.value == :Y
  end

  def no_vote_count_subquery do
    from v in vote_count_subquery(), where: v.value == :N
  end

  def list_all_nominations do
    Repo.all(Nomination)
  end

  @doc """
  Returns the list of nominations for a given date (very likely today).

  ## Examples

      iex> list_nominations(date)
      [%Nomination{}, ...]

  """
  def list_nominations(date) do
    {start_datetime, end_datetime} = Endowment.voting_period_for(date)

    query = from nom in Nomination,
      left_join: yv in subquery(yes_vote_count_subquery()),
      on: yv.nomination_id == nom.id,
      left_join: nv in subquery(no_vote_count_subquery()),
      on: nv.nomination_id == nom.id,
      select: %{id: nom.id, name: nom.name, pitch: nom.pitch, percentage: nom.percentage, inserted_at: nom.inserted_at, yes_vote_count: yv.vote_count, no_vote_count: nv.vote_count},
      where: nom.inserted_at >= ^start_datetime and nom.inserted_at < ^end_datetime
    Repo.all(query)
      #|> Repo.preload([:member, :votes])
  end

  def list_nominations_with_votes_by(member, date) do
    {start_datetime, end_datetime} = Endowment.voting_period_for(date)

    query = from nom in Nomination,
      left_join: yv in subquery(yes_vote_count_subquery()),
      on: yv.nomination_id == nom.id,
      left_join: nv in subquery(no_vote_count_subquery()),
      on: nv.nomination_id == nom.id,
      left_join: v in Vote,
      on: v.nomination_id == nom.id and v.member_id == ^member.id,
      select: %{id: nom.id, name: nom.name, pitch: nom.pitch, percentage: nom.percentage, inserted_at: nom.inserted_at, yes_vote_count: yv.vote_count, no_vote_count: nv.vote_count, vote_value: v.value},
      where: nom.inserted_at >= ^start_datetime and nom.inserted_at < ^end_datetime

    Repo.all(query)
      #|> Repo.preload([:member, :votes])
  end

  #remove any nominations where no votes >= yes votes
  def filter_nominations(nominations) do
    Enum.filter(nominations,
      fn nom -> (nom.yes_vote_count||0) > (nom.no_vote_count||0) end)
  end

  def calculate_percentages!(nominations) do
    filtered = nominations |> filter_nominations

    total_yes_votes =
    if filtered != [] do
      filtered
      |> Enum.map(fn nom -> nom.yes_vote_count || 0 end)
      |> Enum.reduce(&+/2)
    else
      0
    end

    total_no_votes =
    if filtered != [] do
      filtered
      |> Enum.map(fn nom -> nom.no_vote_count || 0 end)
      |> Enum.reduce(&+/2)
    else
      0
    end

    Enum.each(nominations, fn(nomination) ->
      y = nomination.yes_vote_count || 0
      n = nomination.no_vote_count || 0

      pct = if (nomination.yes_vote_count||0) > (nomination.no_vote_count||0) do
        (1.0 * y - n)/(total_yes_votes - total_no_votes)
      else
        0.0
      end

      #TODO: Optimize - this part is very slow (2N queries for N nominations)
      #We can't just call update_nomination b/c it expects a %Nomination{}
      {:ok, _} =
        get_nomination!(nomination.id)
          |> update_nomination(%{percentage: pct})
    end)

    nominations
  end

  def archived?(nomination = %Nomination{}) do
    last_balance = Endowment.get_last_balance!()

    nomination_date = Calendar.NaiveDateTime.to_date(nomination.inserted_at)
    nomination_date < last_balance.date
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

      iex> get_vote!(123, 456)
      %Vote{}

      iex> get_vote!(456, 789)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(member_id, nomination_id) do
    query = from v in Vote,
              where: v.member_id==^member_id and v.nomination_id==^nomination_id
    Repo.one!(query)
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
    #TODO: fix this up
    nomination_id =
    cond do
      Map.has_key?(attrs, "nomination_id") -> attrs["nomination_id"]
      Map.has_key?(attrs, :nomination_id) -> attrs.nomination_id
    end

    nomination = nomination_id && get_nomination!(nomination_id)

    if nomination && archived?(nomination) do
      {:error, "Cannot vote on archived nomination."}
    else
      %Vote{}
      |> Vote.changeset(attrs)
      |> Repo.insert()
    end
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
end
