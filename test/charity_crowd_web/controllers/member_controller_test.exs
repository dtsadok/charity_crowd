defmodule CharityCrowdWeb.MemberControllerTest do
  use CharityCrowdWeb.ConnCase
  import CharityCrowd.Fixtures

  @create_attrs %{nickname: "some nickname", first: "Daniel", last: "Tsadok", email: "daniel@example.com", password: "some password"}
  #@update_attrs %{nickname: "some updated nickname", password: "some updated password"}
  @invalid_attrs %{nickname: nil, password: nil}

  #describe "index" do
  #  test "lists all members", %{conn: conn} do
  #    conn = get(conn, Routes.member_path(conn, :index))
  #    assert html_response(conn, 200) =~ "Listing Members"
  #  end
  #end

  describe "Sign up page" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.member_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign up"
    end
  end

  describe "create member" do
    test "redirects to home when data is valid", %{conn: conn} do
      invite_code = fixture_invite_code(%{active: true})
      conn = post(conn, Routes.member_path(conn, :create), member: @create_attrs, invite_code: invite_code.code)

      assert redirected_to(conn) == Routes.page_path(conn, :index)

      conn = get(conn, Routes.page_path(conn, :index))
      assert html_response(conn, 200) =~ "CharityCrowd"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invite_code = fixture_invite_code(%{active: true})
      conn = post(conn, Routes.member_path(conn, :create), member: @invalid_attrs, invite_code: invite_code.code)
      assert html_response(conn, 422) =~ "Sign up"
    end

    test "renders errors when invite_code is inactive", %{conn: conn} do
      invite_code = fixture_invite_code(%{active: false})
      assert invite_code.active == false
      conn = post(conn, Routes.member_path(conn, :create), member: @create_attrs, invite_code: invite_code.code)
      assert html_response(conn, 422) =~ "Sign up"
    end
  end

  #describe "edit member" do
  #  setup [:create_member]
  #
  #  test "renders form for editing chosen member", %{conn: conn, member: member} do
  #    conn = get(conn, Routes.member_path(conn, :edit, member))
  #    assert html_response(conn, 200) =~ "Edit Member"
  #  end
  #end

  #describe "update member" do
  #  setup [:create_member]
  #
  #  test "redirects when data is valid", %{conn: conn, member: member} do
  #    conn = put(conn, Routes.member_path(conn, :update, member), member: @update_attrs)
  #    assert redirected_to(conn) == Routes.member_path(conn, :show, member)
  #
  #    conn = get(conn, Routes.member_path(conn, :show, member))
  #    assert html_response(conn, 200) =~ "some updated nickname"
  #  end
  #
  #  test "renders errors when data is invalid", %{conn: conn, member: member} do
  #    conn = put(conn, Routes.member_path(conn, :update, member), member: @invalid_attrs)
  #    assert html_response(conn, 200) =~ "Edit Member"
  #  end
  #end

  #describe "delete member" do
  #  setup [:create_member]
  #
  #  test "deletes chosen member", %{conn: conn, member: member} do
  #    conn = delete(conn, Routes.member_path(conn, :delete, member))
  #    assert redirected_to(conn) == Routes.member_path(conn, :index)
  #    assert_error_sent 404, fn ->
  #      get(conn, Routes.member_path(conn, :show, member))
  #    end
  #  end
  #end

  #defp create_member(_) do
  #  member = fixture(:member)
  #  %{member: member}
  #end
end
