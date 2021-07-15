defmodule CharityCrowd.Grants.VotingPeriod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "voting_periods" do
    field :start_date, :date
  end

  @doc false
  def changeset(voting_period, attrs) do
    voting_period
    |> cast(attrs, [:start_date])
    |> validate_required([:start_date])
  end
end
