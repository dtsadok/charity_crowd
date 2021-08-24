defmodule Mix.Tasks.VotingPeriod.Create do
  use Mix.Task
  alias CharityCrowd.Grants

  @shortdoc "Creates a new voting period"

  @moduledoc """
    Usage: mix voting_period.create [start_date]
    Date should be in ISO-8601 format (YYYY-MM-DD)
  """

  def run(args) do
    Mix.Task.run "app.start"

    start_date =
    if length(args) == 0 do
      Calendar.Date.today!("America/New_York")
    else
      {:ok, d} = hd(args) |> Date.from_iso8601
      d
    end

    Mix.shell().info "Creating new Voting Period"

    {:ok, _voting_period} = Grants.create_voting_period(%{start_date: start_date})
  end
end
