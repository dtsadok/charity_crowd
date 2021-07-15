defmodule CharityCrowd.Grants do
  @moduledoc """
  The Grants context.
  """

  import Ecto.Query, warn: false
  alias CharityCrowd.Repo

  alias CharityCrowd.Grants.Nomination
  alias CharityCrowd.Grants.Vote

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
  Returns the list of nominations for a given date (or today by default).

  ## Examples

      iex> list_nominations(date)
      [%Nomination{}, ...]

  """
  def list_nominations(date \\ nil) do
    date = date || Calendar.Date.today!("America/New_York")
    {start_datetime, end_datetime} = voting_period_for(date)

    query = from nom in Nomination,
      left_join: yv in subquery(yes_vote_count_subquery()),
      on: yv.nomination_id == nom.id,
      left_join: nv in subquery(no_vote_count_subquery()),
      on: nv.nomination_id == nom.id,
      select: %{id: nom.id, member_id: nom.member_id, name: nom.name, pitch: nom.pitch, percentage: nom.percentage, inserted_at: nom.inserted_at, yes_vote_count: yv.vote_count, no_vote_count: nv.vote_count},
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

  def current?(nomination = %Nomination{}) do
    last_voting_period = get_last_voting_period!()

    nomination_date = Calendar.NaiveDateTime.to_date(nomination.inserted_at)
    nomination_date >= last_voting_period.start_date
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
      |> Repo.preload([:nomination])
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
    new_vote = %Vote{} |> Vote.changeset(attrs)

    nomination_id = new_vote.changes.nomination_id
    nomination = nomination_id && get_nomination!(nomination_id)

    cond do
      nomination && !current?(nomination) ->
        {:error, "Cannot vote on archived nomination."}
      true ->
        Repo.insert(new_vote)
    end
  end

  alias CharityCrowd.Grants.VotingPeriod

  def get_last_voting_period! do
    query = from vp in VotingPeriod,
      order_by: [desc: :start_date],
      limit: 1

    Repo.one!(query)
  end

  def get_prev_voting_period_for(date) do
    query = from vp in VotingPeriod,
      where: vp.start_date <= ^date,
      order_by: [desc: :start_date],
      limit: 1

    Repo.one(query)
  end

  def get_next_voting_period_for(date) do
    query = from vp in VotingPeriod,
      where: vp.start_date > ^date,
      order_by: [asc: :start_date],
      limit: 1

    Repo.one(query)
  end

  def voting_period_for(date) do
    #TODO: Globalize
    tz = "America/New_York"
    today = Calendar.Date.today!(tz)
    tomorrow = Calendar.Date.next_day! today
    prev_voting_period = get_prev_voting_period_for(date) || get_last_voting_period!() #if date is prior to last voting_period date
    next_voting_period = get_next_voting_period_for(date)
    start_date = prev_voting_period.start_date
    end_date = if next_voting_period do
      next_voting_period.start_date
    else
      tomorrow
    end

    start_datetime = Calendar.DateTime.from_date_and_time_and_zone!(start_date, ~T[00:00:00], tz)
    end_datetime = Calendar.DateTime.from_date_and_time_and_zone!(end_date, ~T[00:00:00], tz)

    #now shift time zone to UTC so it matches nomination timestamps
    start_datetime = Calendar.DateTime.shift_zone!(start_datetime, "UTC")
    end_datetime = Calendar.DateTime.shift_zone!(end_datetime, "UTC")

    {start_datetime, end_datetime}
  end

  @doc """
  Returns the list of voting_periods.

  ## Examples

      iex> list_voting_periods()
      [%VotingPeriod{}, ...]

  """
  def list_voting_periods do
    Repo.all(VotingPeriod)
  end

  @doc """
  Creates a voting_period.

  ## Examples

      iex> create_voting_period(%{field: value})
      {:ok, %VotingPeriod{}}

      iex> create_voting_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_voting_period(attrs \\ %{}) do
    %VotingPeriod{}
    |> VotingPeriod.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking voting_period changes.

  ## Examples

      iex> change_voting_period(voting_period)
      %Ecto.Changeset{data: %VotingPeriod{}}

  """
  def change_voting_period(%VotingPeriod{} = voting_period, attrs \\ %{}) do
    VotingPeriod.changeset(voting_period, attrs)
  end
end
