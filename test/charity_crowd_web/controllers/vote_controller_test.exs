defmodule CharityCrowdWeb.VoteControllerTest do
  use CharityCrowdWeb.ConnCase
  import CharityCrowd.Fixtures
  alias CharityCrowd.Grants

  describe "create vote" do
    setup [:create_balance]

    test "with login redirects to nominations when data is valid", %{conn: conn} do
      conn = login_as conn, fixture_member()
      nomination = fixture_nomination()
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{nomination_id: nomination.id, value: :Y})

      assert redirected_to(conn) == Routes.nomination_path(conn, :index)
    end

    test "with login renders errors when data is invalid", %{conn: conn} do
      conn = login_as conn, fixture_member()
      nomination = fixture_nomination()
      invalid_attrs = %{nomination_id: nomination.id, value: :Z}
      conn = post(conn, Routes.vote_path(conn, :create), vote: invalid_attrs)
      assert html_response(conn, 422) =~ "invalid"
    end

    test "with no login redirects to login page", %{conn: conn} do
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{})
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "does not allow me to vote on my own nomination", %{conn: conn} do
      member = fixture_member()
      nomination = fixture_nomination(member: member)

      conn = login_as conn, member
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{nomination_id: nomination.id, value: :Y})
      assert html_response(conn, 422) =~ "Cannot vote on own nomination"
    end

    test "does not allow me to vote more than 3 times per voting period", %{conn: conn} do
      member = fixture_member()
      fixture_ballot(%{member: member})
      fixture_ballot(%{member: member})
      fixture_ballot(%{member: member})
      nomination = fixture_nomination()

      conn = login_as conn, member
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{nomination_id: nomination.id, value: :Y})
      assert html_response(conn, 422) =~ "No more votes for this voting period"
    end

    test "updates nomination percentage", %{conn: conn} do
      member = fixture_member()
      nomination = fixture_nomination()

      conn = login_as conn, member
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{nomination_id: nomination.id, value: :Y})
      assert redirected_to(conn) == Routes.nomination_path(conn, :index)

      nomination = Grants.get_nomination! nomination.id
      assert nomination.percentage == 1.0
    end

    test "fails on an old nomination", %{conn: conn} do
      #set last Balance in the future so nomination will be archived
      today = Calendar.Date.today_utc
      tomorrow = Calendar.Date.next_day! today
      fixture_balance(1000, tomorrow)

      conn = login_as conn, fixture_member()
      nomination = fixture_nomination()
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{nomination_id: nomination.id, value: :Y})

      assert html_response(conn, 422) =~ "Cannot vote on archived nomination"
    end
  end

  defp create_balance(_) do
    balance = fixture_balance()
    %{balance: balance}
  end
end
