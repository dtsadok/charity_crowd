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

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.nomination_path(conn, :show, id)

      #conn = get(conn, Routes.nomination_path(conn, :show, id))
      #assert html_response(conn, 200) =~ "Show Vote"
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

    test "does not allow me to double-vote", %{conn: conn} do
      member = fixture_member()
      nomination = fixture_nomination(member: member)

      vote = fixture_vote(member: member, nomination: nomination, value: :Y)

      conn = login_as conn, member
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{nomination_id: vote.nomination_id, value: :Y})
      assert html_response(conn, 422) =~ "invalid"
    end

    test "updates nomination percentage", %{conn: conn} do
      member = fixture_member()
      nomination = fixture_nomination(member: member)

      conn = login_as conn, member
      conn = post(conn, Routes.vote_path(conn, :create), vote: %{nomination_id: nomination.id, value: :Y})
      assert redirected_to(conn) == Routes.nomination_path(conn, :show, nomination.id)

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

      assert html_response(conn, 422) =~ "invalid"
    end
  end

  describe "delete vote" do
    setup [:create_balance, :create_vote]

    test "when owner deletes chosen vote", %{conn: conn, vote: vote} do
      conn = login_as conn, vote.member
      conn = delete(conn, Routes.vote_path(conn, :delete, vote.nomination_id))

      assert redirected_to(conn) == Routes.nomination_path(conn, :index)
    end

    test "when not owner raises error", %{conn: conn, vote: vote} do
      conn = login_as conn, fixture_member("other", "other@example.com")
      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, Routes.vote_path(conn, :delete, vote.nomination_id))
      end
    end

    test "cannot delete vote on old nomination", %{conn: conn, vote: vote} do
      #set last Balance in the future so nomination will be archived
      today = Calendar.Date.today_utc
      tomorrow = Calendar.Date.next_day! today
      fixture_balance(1000, tomorrow)

      conn = login_as conn, vote.member
      conn = delete(conn, Routes.vote_path(conn, :delete, vote.nomination_id))

      assert html_response(conn, 422)
      assert Grants.get_vote!(vote.member_id, vote.nomination_id)
    end

    test "updates nomination percentage", %{conn: conn, vote: vote} do
      {:ok, _nomination} = Grants.update_nomination vote.nomination, %{percentage: 1.0}

      conn = login_as conn, vote.member
      conn = delete(conn, Routes.vote_path(conn, :delete, vote.nomination_id))

      assert redirected_to(conn) == Routes.nomination_path(conn, :index)

      nomination = Grants.get_nomination! vote.nomination_id
      assert nomination.percentage == 0.0
    end
  end

  defp create_vote(_) do
    vote = fixture_vote()
    %{vote: vote}
  end

  defp create_balance(_) do
    balance = fixture_balance()
    %{balance: balance}
  end
end
