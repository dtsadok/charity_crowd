defmodule CharityCrowdWeb.SessionControllerTest do
  use CharityCrowdWeb.ConnCase
  import CharityCrowd.Fixtures

  describe "login page" do
    test "returns 200", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign in"
    end
  end

  describe "login" do
    test "with correct login redirects to home", %{conn: conn} do
      member = fixture_member()
      conn = post(conn, Routes.session_path(conn, :create), email: member.email, password: "1234")
      assert redirected_to(conn) == "/"
    end

    test "with incorrect login returns 401", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), email: "noone@example.com", password: "1234")
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end
end
