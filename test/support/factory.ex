defmodule CharityCrowd.Factory do
  use ExMachina.Ecto, repo: CharityCrowd.Repo

  def nomination_factory do
    %CharityCrowd.Grants.Nomination{
      name: "Local Soup Kitchen",
      pitch: "This is a great soup kitchen."
    }
  end
end
