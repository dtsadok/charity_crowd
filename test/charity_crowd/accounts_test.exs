defmodule CharityCrowd.AccountsTest do
  use CharityCrowd.DataCase

  alias CharityCrowd.Accounts

  describe "members" do
    alias CharityCrowd.Accounts.Member

    @valid_attrs %{nickname: "some nickname", password: "some password"}
    @update_attrs %{nickname: "some updated nickname", password: "some updated password"}
    @invalid_attrs %{nickname: nil, password: nil}

    def member_fixture(attrs \\ %{}) do
      {:ok, member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_member()

      member
    end

    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Accounts.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Accounts.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      assert {:ok, %Member{} = member} = Accounts.create_member(@valid_attrs)
      assert member.nickname == "some nickname"
      assert member.password == "some password"
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      assert {:ok, %Member{} = member} = Accounts.update_member(member, @update_attrs)
      assert member.nickname == "some updated nickname"
      assert member.password == "some updated password"
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = member_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_member(member, @invalid_attrs)
      assert member == Accounts.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = member_fixture()
      assert {:ok, %Member{}} = Accounts.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Accounts.change_member(member)
    end
  end
end