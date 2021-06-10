#Based on https://blog.danielberkompas.com/2015/07/16/fixtures-for-ecto/

defmodule CharityCrowd.Fixtures do
  alias CharityCrowd.Accounts
  alias CharityCrowd.Grants

  def fixture(:member) do
    {:ok, member} = %{nickname: "daniel", password: "1234"}
      |> Accounts.create_member()

    #load from DB to preload associations
    Accounts.get_member!(member.id)
  end

  def fixture(:nomination, assoc \\ []) do
    member = assoc[:member] || fixture(:member)
    attrs = %{
      member_id: member.id,
      name: "Fixtures for Ecto",
      pitch: "Fixtures for Ecto"
    }
    {:ok, nomination} = Grants.create_nomination(attrs)
    #load from DB to preload associations
    Grants.get_nomination!(nomination.id)
  end
end
