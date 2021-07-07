#Based on https://blog.danielberkompas.com/2015/07/16/fixtures-for-ecto/

defmodule CharityCrowd.Fixtures do
  alias CharityCrowd.Accounts
  alias CharityCrowd.Grants
  alias CharityCrowd.Endowment

  def fixture_member(nickname \\ "daniel", email \\ "daniel@example.com") do
    {:ok, member} = %{nickname: nickname, email: email, password: "1234"}
      |> Accounts.create_member()

    #load from DB to preload associations
    Accounts.get_member!(member.id)
  end

  def fixture_nomination(assoc \\ []) do
    member = assoc[:member] || fixture_member("nominator", "nominator@example.com")
    attrs = %{
      member_id: member.id,
      name: "Charity",
      pitch: "This is a charity"
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

  def fixture_balance(amount_cents \\ 100_000_00, date \\ nil) do
      date = date || Calendar.Date.today!("America/New_York")
      {:ok, balance} =
        %{amount_cents: amount_cents, date: date}
        |> Endowment.create_balance()

      balance
  end
end
