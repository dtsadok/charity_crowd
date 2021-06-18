defmodule Mix.Tasks.InviteCodes.Create do
  use Mix.Task
  alias CharityCrowd.Accounts

  @shortdoc "Creates invite codes"

  @moduledoc """
  """

  def run(_args) do
    num = 25
    Mix.Task.run "app.start"
    Mix.shell().info "Generating #{num} invite codes..."

    #loop based on https://stackoverflow.com/questions/47533781/best-way-to-simulate-a-for-loop-in-elixir
    Enum.each(0..num-1, fn(_x) ->
      #string randomizer based on https://gist.github.com/ahmadshah/8d978bbc550128cca12dd917a09ddfb7

      #removed 0,O,1,I to avoid ambiguity
      alphabets = "ABCDEFGHJKLMNPQRSTUVWXYZ"
      numbers = "23456789"
      char_list = String.split(alphabets <> numbers, "", trim: true)

      code =
      (1..6)
      |> Enum.reduce([], fn(_, acc) -> [Enum.random(char_list) | acc] end)
      |> Enum.join("")

      Mix.shell().info "#{code}"

      {:ok, _} = Accounts.create_invite_code(%{code: code, active: true})
    end)

    Mix.shell().info "Done!"
  end

  # We can define other functions as needed here.
end
