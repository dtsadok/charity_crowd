defmodule CharityCrowd.GrantsTest do
  use CharityCrowd.DataCase
  import CharityCrowd.Fixtures

  alias CharityCrowd.Grants

  describe "nominations" do
    alias CharityCrowd.Grants.Nomination

    @valid_attrs %{name: "some name", pitch: "some pitch"}
    @update_attrs %{name: "some updated name", pitch: "some updated pitch", percentage: 0.42}
    @invalid_attrs %{name: nil, pitch: nil}

    setup [:create_balance]

    test "list_nominations/1 returns nominations for given date" do
      member = fixture_member()
      nomination = fixture_nomination(member: member)

      today = Calendar.Date.today!("America/New_York")
      assert Grants.list_nominations(today) == [%{id: nomination.id, inserted_at: nomination.inserted_at, name: "Charity", no_vote_count: nil, percentage: 0, pitch: "This is a charity", yes_vote_count: nil}]
    end

    test "list_nominations_with_votes_by/2 returns nominations for given date with votes by given member" do
      member = fixture_member()
      nomination = fixture_nomination(member: member)
      vote = fixture_vote(member: member, nomination: nomination, value: :N)

      today = Calendar.Date.today!("America/New_York")
      nomination_with_votes = Grants.list_nominations_with_votes_by(member, today) |> hd
      assert nomination_with_votes.id == nomination.id
      assert nomination_with_votes.vote_value == vote.value
    end

    test "filter_nominations/1 only returns nominations where Y > N" do
      member = fixture_member("member", "member@example.com")
      nomination = fixture_nomination(member: member)
      fixture_vote(%{member: member, nomination: nomination}, :N)

      #load from DB so we have vote counts
      today = Calendar.Date.today!("America/New_York")
      nominations = Grants.list_nominations today

      assert nominations != []
      assert Grants.filter_nominations(nominations) == []
    end

    test "calculate_percentages/1 with empty list does nothing" do
      Grants.calculate_percentages!([])
    end

    test "calculate_percentages/1 sets the percentage for each nomination" do
      member1 = fixture_member("member1", "member1@example.com")
      member2 = fixture_member("member2", "member2@example.com")
      member3 = fixture_member("member3", "member3@example.com")
      member4 = fixture_member("member4", "member4@example.com")

      nomination1 = fixture_nomination(member: member1) #80%
      fixture_vote(%{member: member1, nomination: nomination1}, :Y)
      fixture_vote(%{member: member2, nomination: nomination1}, :Y)
      fixture_vote(%{member: member3, nomination: nomination1}, :Y)
      fixture_vote(%{member: member4, nomination: nomination1}, :Y)

      nomination2 = fixture_nomination(member: member1) #0% - tie
      fixture_vote(%{member: member1, nomination: nomination2}, :Y)
      fixture_vote(%{member: member2, nomination: nomination2}, :Y)
      fixture_vote(%{member: member3, nomination: nomination2}, :N)
      fixture_vote(%{member: member4, nomination: nomination2}, :N)

      nomination3 = fixture_nomination(member: member1) #20%
      fixture_vote(%{member: member1, nomination: nomination3}, :Y)
      fixture_vote(%{member: member2, nomination: nomination3}, :Y)
      fixture_vote(%{member: member3, nomination: nomination3}, :N)

      nomination4 = fixture_nomination(member: member1) #0% - more N votes
      fixture_vote(%{member: member1, nomination: nomination4}, :N)
      fixture_vote(%{member: member2, nomination: nomination4}, :N)
      fixture_vote(%{member: member3, nomination: nomination4}, :Y)

      #load from DB so we have vote counts
      today = Calendar.Date.today!("America/New_York")
      Grants.list_nominations(today)
      |> Grants.filter_nominations
      |> Grants.calculate_percentages!

      nomination1 = Grants.get_nomination! nomination1.id
      nomination2 = Grants.get_nomination! nomination2.id
      nomination3 = Grants.get_nomination! nomination3.id
      nomination4 = Grants.get_nomination! nomination4.id

      assert nomination1.percentage == 0.80
      assert nomination2.percentage == 0
      assert nomination3.percentage == 0.20
      assert nomination4.percentage == 0
    end

    test "archived? returns false if balance.date <= nomination.date" do
      nomination = fixture_nomination()

      assert !Grants.archived?(nomination)
    end

    test "archived? returns true if balance.date > nomination.date" do
      #set last Balance in the future so nomination will be considered archived
      today = Calendar.Date.today_utc
      tomorrow = Calendar.Date.next_day! today
      fixture_balance(1000, tomorrow)

      nomination = fixture_nomination()

      assert Grants.archived?(nomination)
    end

    test "get_nomination!/1 returns the nomination with given id" do
      nomination = fixture_nomination()
      assert Grants.get_nomination!(nomination.id) == %{nomination | percentage: 0}
    end

    test "create_nomination/1 with valid data creates a nomination" do
      member = fixture_member()
      attrs = Map.put(@valid_attrs, :member_id, member.id)

      assert {:ok, %Nomination{} = nomination} = Grants.create_nomination(attrs)
      assert nomination.name == "some name"
      assert nomination.pitch == "some pitch"
      assert nomination.percentage == 0
    end

    test "create_nomination/1 with invalid data returns error changeset" do
      member = fixture_member()
      attrs = Map.put(@invalid_attrs, :member_id, member.id)

      assert {:error, %Ecto.Changeset{}} = Grants.create_nomination(attrs)
    end

    test "update_nomination/2 with valid data updates the nomination" do
      nomination = fixture_nomination()
      assert {:ok, %Nomination{} = nomination} = Grants.update_nomination(nomination, @update_attrs)
      assert nomination.name == "some updated name"
      assert nomination.pitch == "some updated pitch"
      assert nomination.percentage == 0.42
    end

    test "update_nomination/2 with invalid data returns error changeset" do
      nomination = fixture_nomination()
      assert {:error, %Ecto.Changeset{}} = Grants.update_nomination(nomination, @invalid_attrs)
      assert %{nomination | percentage: 0} == Grants.get_nomination!(nomination.id)
    end

    test "delete_nomination/1 deletes the nomination" do
      nomination = fixture_nomination()
      assert {:ok, %Nomination{}} = Grants.delete_nomination(nomination)
      assert_raise Ecto.NoResultsError, fn -> Grants.get_nomination!(nomination.id) end
    end

    test "change_nomination/1 returns a nomination changeset" do
      nomination = fixture_nomination()
      assert %Ecto.Changeset{} = Grants.change_nomination(nomination)
    end
  end

  describe "votes" do
    alias CharityCrowd.Grants.Vote

    setup [:create_balance]

    test "list_votes/0 returns all votes" do
      vote = fixture_vote()
      assert Grants.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = fixture_vote()
      assert Grants.get_vote!(vote.member_id, vote.nomination_id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      nomination = fixture_nomination()

      attrs = %{member_id: nomination.member_id, nomination_id: nomination.id, value: :Y}
      assert {:ok, %Vote{} = vote} = Grants.create_vote(attrs)
      assert vote.member_id == nomination.member_id
      assert vote.nomination_id == nomination.id
    end

    test "create_vote/1 with invalid data returns error changeset" do
      nomination = fixture_nomination()
      attrs = %{member_id: nomination.member_id, nomination_id: nomination.id, value: :Z}
      assert {:error, %Ecto.Changeset{}} = Grants.create_vote(attrs)
    end

    test "create_vote/1 with archived nomination returns error" do
      #set last Balance in the future so nomination will be considered archived
      today = Calendar.Date.today_utc
      tomorrow = Calendar.Date.next_day! today
      fixture_balance(1000, tomorrow)

      nomination = fixture_nomination()
      valid_attrs = %{member_id: nomination.member_id, nomination_id: nomination.id, value: :Y}

      assert Grants.archived?(nomination)

      assert {:error, _} = Grants.create_vote(valid_attrs)
    end

    test "voting sets nomination vote_counts" do
      member1 = fixture_member("member1", "member1@example.com")
      member2 = fixture_member("member2", "member2@example.com")
      member3 = fixture_member("member3", "member3@example.com")
      member4 = fixture_member("member4", "member4@example.com")

      nomination = fixture_nomination(member: member1)
      fixture_vote(%{member: member1, nomination: nomination}, :Y)
      fixture_vote(%{member: member2, nomination: nomination}, :Y)
      fixture_vote(%{member: member3, nomination: nomination}, :Y)
      fixture_vote(%{member: member4, nomination: nomination}, :N)

      today = Calendar.Date.today!("America/New_York")
      nominations = Grants.list_nominations today

      assert hd(nominations).yes_vote_count == 3
      assert hd(nominations).no_vote_count == 1
    end

    test "voting no sets nomination.no_vote_count" do
      member = fixture_member("voter", "voter@example.com")
      _vote = fixture_vote(%{member: member}, :N)

      today = Calendar.Date.today!("America/New_York")
      nominations = Grants.list_nominations today

      assert hd(nominations).yes_vote_count == nil
      assert hd(nominations).no_vote_count == 1
    end

    test "delete_vote/1 deletes the vote" do
      vote = fixture_vote()
      assert {:ok, %Vote{}} = Grants.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Grants.get_vote!(vote.member_id, vote.nomination_id) end
    end

    #test "change_vote/1 returns a vote changeset" do
    #  vote = fixture_vote()
    #  assert %Ecto.Changeset{} = Grants.change_vote(vote)
    #end
  end

  defp create_balance(_) do
    balance = fixture_balance()
    %{balance: balance}
  end
end
