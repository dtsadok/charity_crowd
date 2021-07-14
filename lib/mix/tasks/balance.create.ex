defmodule Mix.Tasks.Balance.Create do
  use Mix.Task
  alias CharityCrowd.Endowment

  @shortdoc "Creates a new balance"

  @moduledoc """
  """

  def run(args) do
    Mix.Task.run "app.start"

    if length(args) == 0 do
      Mix.shell().info "Usage: mix balance.create amount_cents"
    else
      Mix.shell().info "Creating new Balance"
      {amount_cents, _} = hd(args) |> Integer.parse

      today = Calendar.Date.today!("America/New_York")
      {:ok, _balance} = Endowment.create_balance(%{date: today, amount_cents: amount_cents})
    end
  end
end
