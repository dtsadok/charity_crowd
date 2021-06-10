defmodule CharityCrowd.GrantsTest do
  use CharityCrowd.DataCase

  alias CharityCrowd.Grants

  describe "nominations" do
    alias CharityCrowd.Grants.Nomination

    @valid_attrs %{name: "some name", pitch: "some pitch", percentage: 42}
    @update_attrs %{name: "some updated name", pitch: "some updated pitch", percentage: 43}
    @invalid_attrs %{name: nil, pitch: nil, percentage: nil}

    def nomination_fixture(attrs \\ %{}) do
      {:ok, nomination} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Grants.create_nomination()

      nomination
    end

    test "list_nominations/0 returns all nominations" do
      nomination = nomination_fixture()
      assert Grants.list_nominations() == [%{nomination | percentage: 0}]
    end

    test "get_nomination!/1 returns the nomination with given id" do
      nomination = nomination_fixture()
      assert Grants.get_nomination!(nomination.id) == %{nomination | percentage: 0}
    end

    test "create_nomination/1 with valid data creates a nomination" do
      assert {:ok, %Nomination{} = nomination} = Grants.create_nomination(@valid_attrs)
      assert nomination.name == "some name"
      assert nomination.pitch == "some pitch"
      assert nomination.percentage == 0
    end

    test "create_nomination/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grants.create_nomination(@invalid_attrs)
    end

    test "update_nomination/2 with valid data updates the nomination" do
      nomination = nomination_fixture()
      assert {:ok, %Nomination{} = nomination} = Grants.update_nomination(nomination, @update_attrs)
      assert nomination.name == "some updated name"
      assert nomination.pitch == "some updated pitch"
      assert nomination.percentage == 0
    end

    test "update_nomination/2 with invalid data returns error changeset" do
      nomination = nomination_fixture()
      assert {:error, %Ecto.Changeset{}} = Grants.update_nomination(nomination, @invalid_attrs)
      assert %{nomination | percentage: 0} == Grants.get_nomination!(nomination.id)
    end

    test "delete_nomination/1 deletes the nomination" do
      nomination = nomination_fixture()
      assert {:ok, %Nomination{}} = Grants.delete_nomination(nomination)
      assert_raise Ecto.NoResultsError, fn -> Grants.get_nomination!(nomination.id) end
    end

    test "change_nomination/1 returns a nomination changeset" do
      nomination = nomination_fixture()
      assert %Ecto.Changeset{} = Grants.change_nomination(nomination)
    end
  end
end
