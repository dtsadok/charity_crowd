defmodule CharityCrowd.EndowmentTest do
  use CharityCrowd.DataCase

  alias CharityCrowd.Endowment

  describe "balances" do
    alias CharityCrowd.Endowment.Balance

    @valid_attrs %{amount_cents: 4200, date: ~D[2021-07-03]}
    @invalid_attrs %{amount_cents: nil, date: nil}

    test "get_last_balance/0 returns most recent balance" do
      today = Calendar.Date.today! "America/New_York"
      yesterday = Calendar.Date.prev_day! today
      fixture_balance(1000, yesterday)
      fixture_balance(2000, today)
      b = Endowment.get_last_balance()
      assert b.amount_cents == 2000
    end

    test "list_balances/0 returns all balances" do
      balance = fixture_balance()
      assert Endowment.list_balances() == [balance]
    end

    test "get_balance!/1 returns the balance with given id" do
      balance = fixture_balance()
      assert Endowment.get_balance!(balance.id) == balance
    end

    test "create_balance/1 with valid data creates a balance" do
      assert {:ok, %Balance{} = balance} = Endowment.create_balance(@valid_attrs)
      assert balance.amount_cents == 4200
    end

    test "create_balance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Endowment.create_balance(@invalid_attrs)
    end

    test "change_balance/1 returns a balance changeset" do
      balance = fixture_balance()
      assert %Ecto.Changeset{} = Endowment.change_balance(balance)
    end
  end
end
