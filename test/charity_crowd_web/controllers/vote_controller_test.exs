defmodule CharityCrowdWeb.VoteControllerTest do
  use CharityCrowdWeb.ConnCase
  import CharityCrowd.Fixtures

  @create_attrs %{nomination_id: 42, value: :Y}
  @invalid_attrs %{nomination_id: 42, value: :Z}

  describe "create vote" do
    test "with login redirects to nominations when data is valid", %{conn: conn} do
      conn = login_as conn, fixture_member()
      conn = post(conn, Routes.vote_path(conn, :create), vote: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.nomination_path(conn, :show, id)

      #conn = get(conn, Routes.nomination_path(conn, :show, id))
      #assert html_response(conn, 200) =~ "Show Vote"
    end

    test "with login renders errors when data is invalid", %{conn: conn} do
      conn = login_as conn, fixture_member()
      conn = post(conn, Routes.vote_path(conn, :create), vote: @invalid_attrs)
      assert html_response(conn, 422) =~ "invalid"
    end

    test "with no login redirects to login page", %{conn: conn} do
      conn = post(conn, Routes.vote_path(conn, :create), vote: @invalid_attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "delete vote" do
    setup [:create_vote]

    test "when owner deletes chosen vote", %{conn: conn, vote: vote} do
      conn = login_as conn, vote.member
      conn = delete(conn, Routes.vote_path(conn, :delete, vote))

      assert redirected_to(conn) == Routes.nomination_path(conn, :index)
    end

    test "when not owner returns 401", %{conn: conn, vote: vote} do
      conn = login_as conn, fixture_member("other", "other@example.com")
      conn = delete(conn, Routes.vote_path(conn, :delete, vote))
      assert html_response(conn, 401)
    end
  end

  defp create_vote(_) do
    vote = fixture_vote()
    %{vote: vote}
  end
end
