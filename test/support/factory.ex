defmodule CharityCrowd.Factory do
  use ExMachina.Ecto, repo: CharityCrowd.Repo

  def member_factory do
    %CharityCrowd.Accounts.Member{
      nickname: "daniel",
      password: "1234"
    }
  end

  def nomination_factory do
    %CharityCrowd.Grants.Nomination{
      name: "Local Soup Kitchen",
      pitch: "This is a great soup kitchen."
    }
  end
end
