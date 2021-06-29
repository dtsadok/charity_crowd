#Based on https://blog.danielberkompas.com/2015/07/16/fixtures-for-ecto/

defmodule CharityCrowd.Fixtures do
  alias CharityCrowd.Accounts
  alias CharityCrowd.Grants

  def fixture_member(nickname \\ "daniel", email \\ "daniel@example.com") do
    {:ok, member} = %{nickname: nickname, email: email, password: "1234"}
      |> Accounts.create_member()

    #load from DB to preload associations
    Accounts.get_member!(member.id)
  end

  def fixture_nomination(assoc \\ []) do
    member = assoc[:member] || fixture_member()
    attrs = %{
      member_id: member.id,
      name: "Fixtures for Ecto",
      pitch: "Fixtures for Ecto"
    }
    {:ok, nomination} = Grants.create_nomination(attrs)

    #load from DB to preload associations
    Grants.get_nomination!(nomination.id)
    #nomination
  end

  def fixture_vote(assoc \\ [], value \\ :Y) do
    member = assoc[:member] || fixture_member("voter", "voter@example.com")
    nomination = assoc[:nomination] || fixture_nomination()
    attrs = %{
      member_id: member.id,
      nomination_id: nomination.id,
      value: value
    }
 
    {:ok, _vote} =
        attrs
        |> Grants.create_vote()

    Grants.get_vote!(member.id, nomination.id)
  end

    def fixture_invite_code(attrs \\ %{}) do
      {:ok, invite_code} =
        attrs
        |> Enum.into(%{code: "AAAAAA", active: true})
        |> Accounts.create_invite_code()

      invite_code
    end
end
