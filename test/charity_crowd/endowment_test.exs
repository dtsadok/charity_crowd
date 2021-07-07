defmodule CharityCrowd.EndowmentTest do
  use CharityCrowd.DataCase

  alias CharityCrowd.Endowment

  describe "balances" do
    alias CharityCrowd.Endowment.Balance

    @valid_attrs %{amount_cents: 4200}
    @update_attrs %{amount_cents: 4300}
    @invalid_attrs %{amount_cents: nil}

    def balance_fixture(attrs \\ %{}) do
      {:ok, balance} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Endowment.create_balance()

      balance
    end

    test "get_last_balance/0 returns most recent balance" do
      #make this balance older
      balance_fixture(%{amount_cents: 1000})
      Process.sleep(500)
      balance_fixture(%{amount_cents: 2000})
      b = Endowment.get_last_balance()
      assert b.amount_cents == 2000
    end

    test "list_balances/0 returns all balances" do
      balance = balance_fixture()
      assert Endowment.list_balances() == [balance]
    end

    test "get_balance!/1 returns the balance with given id" do
      balance = balance_fixture()
      assert Endowment.get_balance!(balance.id) == balance
    end

    test "create_balance/1 with valid data creates a balance" do
      assert {:ok, %Balance{} = balance} = Endowment.create_balance(@valid_attrs)
      assert balance.amount_cents == 4200
    end

    test "create_balance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Endowment.create_balance(@invalid_attrs)
    end

    test "update_balance/2 with valid data updates the balance" do
      balance = balance_fixture()
      assert {:ok, %Balance{} = balance} = Endowment.update_balance(balance, @update_attrs)
      assert balance.amount_cents == 4300
    end

    test "update_balance/2 with invalid data returns error changeset" do
      balance = balance_fixture()
      assert {:error, %Ecto.Changeset{}} = Endowment.update_balance(balance, @invalid_attrs)
      assert balance == Endowment.get_balance!(balance.id)
    end

    test "delete_balance/1 deletes the balance" do
      balance = balance_fixture()
      assert {:ok, %Balance{}} = Endowment.delete_balance(balance)
      assert_raise Ecto.NoResultsError, fn -> Endowment.get_balance!(balance.id) end
    end

    test "change_balance/1 returns a balance changeset" do
      balance = balance_fixture()
      assert %Ecto.Changeset{} = Endowment.change_balance(balance)
    end
  end
end
