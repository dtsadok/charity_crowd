defmodule CharityCrowd.GrantsTest do
  use CharityCrowd.DataCase
  import CharityCrowd.Fixtures

  alias CharityCrowd.Grants

  describe "nominations" do
    alias CharityCrowd.Grants.Nomination

    @valid_attrs %{name: "some name", pitch: "some pitch", percentage: 42}
    @update_attrs %{name: "some updated name", pitch: "some updated pitch", percentage: 43}
    @invalid_attrs %{name: nil, pitch: nil, percentage: nil}

    test "list_nominations/0 returns all nominations" do
      member = fixture_member()
      nomination = fixture_nomination(member: member)
      assert Grants.list_nominations() == [%{nomination | percentage: 0}]
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
      assert nomination.percentage == 0
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

    @valid_attrs %{member_id: 42, nomination_id: 42, value: :N}
    @invalid_attrs %{member_id: 42, nomination_id: 42, value: :n}

    test "list_votes/0 returns all votes" do
      vote = fixture_vote()
      assert Grants.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = fixture_vote()
      assert Grants.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      assert {:ok, %Vote{} = vote} = Grants.create_vote(@valid_attrs)
      assert vote.member_id == 42
      assert vote.nomination_id == 42
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grants.create_vote(@invalid_attrs)
    end

    test "creating a yes vote sets nomination.yes_vote_count" do
      member = fixture_member("voter", "voter@example.com")
      vote = fixture_vote(%{member: member}, :Y)
      assert vote.nomination.yes_vote_count == 1
      assert vote.nomination.no_vote_count == 0
    end

    test "creating a no vote sets nomination.no_vote_count" do
      member = fixture_member("voter", "voter@example.com")
      vote = fixture_vote(%{member: member}, :N)
      assert vote.nomination.yes_vote_count == 0
      assert vote.nomination.no_vote_count == 1
    end

    test "delete_vote/1 deletes the vote" do
      vote = fixture_vote()
      assert {:ok, %Vote{}} = Grants.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Grants.get_vote!(vote.id) end
    end

    #test "change_vote/1 returns a vote changeset" do
    #  vote = fixture_vote()
    #  assert %Ecto.Changeset{} = Grants.change_vote(vote)
    #end
  end
end
