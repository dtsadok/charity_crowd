defmodule CharityCrowd.AccountsTest do
  use CharityCrowd.DataCase
  import CharityCrowd.Fixtures

  alias CharityCrowd.Accounts

  describe "members" do
    alias CharityCrowd.Accounts.Member

    @valid_attrs %{nickname: "some nickname", email: "some_email@example.com", password: "some password"}
    @update_attrs %{nickname: "some updated nickname", password: "some updated password"}
    @invalid_attrs %{nickname: nil, password: nil}

    test "list_members/0 returns all members" do
      member = fixture_member()
      members = Accounts.list_members()
      assert length(members) == 1
      assert hd(members).id == member.id
    end

    test "get_member/1 returns the member with given id" do
      member = fixture_member()
      assert Accounts.get_member(member.id) == member
    end

    test "get_member!/1 returns the member with given id" do
      member = fixture_member()
      assert Accounts.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      assert {:ok, %Member{} = member} = Accounts.create_member(@valid_attrs)
      assert member.nickname == "some nickname"
      assert member.email == "some_email@example.com"
      assert {:ok, member} == Argon2.check_pass(member, "some password", hash_key: :password)
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = fixture_member()
      assert {:ok, %Member{} = member} = Accounts.update_member(member, @update_attrs)
      assert member.nickname == "some updated nickname"
      assert {:ok, member} == Argon2.check_pass(member, "some updated password", hash_key: :password)
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = fixture_member()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_member(member, @invalid_attrs)
      assert member == Accounts.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = fixture_member()
      assert {:ok, %Member{}} = Accounts.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = fixture_member()
      assert %Ecto.Changeset{} = Accounts.change_member(member)
    end
  end

  describe "invite_codes" do
    alias CharityCrowd.Accounts.InviteCode

    @valid_attrs %{active: true, code: "some code"}
    @update_attrs %{active: false, code: "some updated code"}
    @invalid_attrs %{active: nil, code: nil}

    test "list_invite_codes/0 returns all invite_codes" do
      invite_code = fixture_invite_code()
      assert Accounts.list_invite_codes() == [invite_code]
    end

    test "get_active_invite_code!/1 returns the invite_code with given code" do
      invite_code = fixture_invite_code()
      assert Accounts.get_active_invite_code!(invite_code.code) == invite_code
    end

    test "create_invite_code/1 with valid data creates a invite_code" do
      assert {:ok, %InviteCode{} = invite_code} = Accounts.create_invite_code(@valid_attrs)
      assert invite_code.active == true
      assert invite_code.code == "some code"
    end

    test "create_invite_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_invite_code(@invalid_attrs)
    end

    test "deactivate_invite_code/1" do
      invite_code = fixture_invite_code()
      assert {:ok, %InviteCode{} = invite_code} = Accounts.update_invite_code(invite_code, %{active: false})
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_active_invite_code!(invite_code.code) end
    end

    test "update_invite_code/2 with valid data updates the invite_code" do
      invite_code = fixture_invite_code()
      assert {:ok, %InviteCode{} = invite_code} = Accounts.update_invite_code(invite_code, @update_attrs)
      assert invite_code.active == false
      assert invite_code.code == "some updated code"
    end

    test "update_invite_code/2 with invalid data returns error changeset" do
      invite_code = fixture_invite_code()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_invite_code(invite_code, @invalid_attrs)
      assert Accounts.get_active_invite_code!(invite_code.code) == invite_code
    end

    test "delete_invite_code/1 deletes the invite_code" do
      invite_code = fixture_invite_code()
      assert {:ok, %InviteCode{}} = Accounts.delete_invite_code(invite_code)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_active_invite_code!(invite_code.code) end
    end

    test "change_invite_code/1 returns a invite_code changeset" do
      invite_code = fixture_invite_code()
      assert %Ecto.Changeset{} = Accounts.change_invite_code(invite_code)
    end
  end

  describe "ballots" do
    alias CharityCrowd.Accounts.Ballot

    @valid_attrs %{date: ~D[2010-04-17], member_id: 42}
    @invalid_attrs %{date: nil, member_id: nil}

    test "count_ballots/2 returns number of ballots for member since given date" do
      today = Calendar.Date.today!("America/New_York")
      member = fixture_member()

      assert Accounts.count_ballots(member, today) == 0

      fixture_ballot(%{member: member})
      assert Accounts.count_ballots(member, today) == 1

      fixture_ballot(%{member: member})
      assert Accounts.count_ballots(member, today) == 2
    end

    test "list_ballots/0 returns all ballots" do
      ballot = fixture_ballot()
      assert Accounts.list_ballots() == [ballot]
    end

    test "create_ballot/1 with valid data creates a ballot" do
      assert {:ok, %Ballot{} = ballot} = Accounts.create_ballot(@valid_attrs)
      assert ballot.date == ~D[2010-04-17]
      assert ballot.member_id == 42
    end

    test "create_ballot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_ballot(@invalid_attrs)
    end

    test "change_ballot/1 returns a ballot changeset" do
      ballot = fixture_ballot()
      assert %Ecto.Changeset{} = Accounts.change_ballot(ballot)
    end
  end
end
