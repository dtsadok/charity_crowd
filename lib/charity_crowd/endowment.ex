defmodule CharityCrowd.Endowment do
  @moduledoc """
  The Endowment context.
  """

  import Ecto.Query, warn: false
  alias CharityCrowd.Repo

  alias CharityCrowd.Endowment.Balance

  @allocation_percentage 0.12

  def get_last_balance! do
    query = from b in Balance,
      order_by: [desc: :date],
      limit: 1

    Repo.one!(query)
  end

  def get_prev_balance_for(date) do
    query = from b in Balance,
      where: b.date <= ^date,
      order_by: [desc: :date],
      limit: 1

    Repo.one(query)
  end

  def get_next_balance_for(date) do
    query = from b in Balance,
      where: b.date > ^date,
      order_by: [asc: :date],
      limit: 1

    Repo.one(query)
  end

  def get_grant_budget_cents(date) do
    b = get_prev_balance_for(date)
    amount_cents = (b && b.amount_cents) || 0
    @allocation_percentage * amount_cents
  end

  @doc """
  Returns the list of balances.

  ## Examples

      iex> list_balances()
      [%Balance{}, ...]

  """
  def list_balances do
    Repo.all(Balance)
  end

  @doc """
  Gets a single balance.

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance!(123)
      %Balance{}

      iex> get_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance!(id), do: Repo.get!(Balance, id)

  @doc """
  Creates a balance.  Naive local time expected (i.e. "midnight" should be local midnight).
  N.B. For now a new balance should only be created when a voting period ends and a new one is about to begin, since the list of nominations uses balance dates as the boundary.  That's the primary purpose of the Balance model.

  ## Examples

      iex> create_balance(%{field: value})
      {:ok, %Balance{}}

      iex> create_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_balance(attrs \\ %{}) do
    %Balance{}
    |> Balance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking balance changes.

  ## Examples

      iex> change_balance(balance)
      %Ecto.Changeset{data: %Balance{}}

  """
  def change_balance(%Balance{} = balance, attrs \\ %{}) do
    Balance.changeset(balance, attrs)
  end

  def voting_period_for(date) do
    #TODO: Globalize
    tz = "America/New_York"
    today = Calendar.Date.today!(tz)
    tomorrow = Calendar.Date.next_day! today
    prev_balance = get_prev_balance_for(date) || get_last_balance!() #if date is prior to last balance date
    next_balance = get_next_balance_for(date)
    start_date = prev_balance.date
    end_date = if next_balance do
      next_balance.date
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
end
