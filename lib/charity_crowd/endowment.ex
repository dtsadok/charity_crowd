defmodule CharityCrowd.Endowment do
  @moduledoc """
  The Endowment context.
  """

  import Ecto.Query, warn: false
  alias CharityCrowd.Repo

  alias CharityCrowd.Endowment.Balance

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
  Creates a balance.

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

  def period_start_end_for(date) do
    tz = "America/New_York" #TODO: Globalize 
    today = Calendar.Date.today! tz
    tomorrow = Calendar.Date.next_day! today
    prev_balance = get_prev_balance_for(date) || get_last_balance!()
    next_balance = get_next_balance_for(date)
    start_date = prev_balance.date
    end_date = if next_balance do
      next_balance.date
    else
      tomorrow
    end

    start_datetime = Calendar.DateTime.from_date_and_time_and_zone!(start_date, ~T[00:00:00], tz)
    end_datetime = Calendar.DateTime.from_date_and_time_and_zone!(end_date, ~T[00:00:00], tz)

    {start_datetime, end_datetime}
  end
end
