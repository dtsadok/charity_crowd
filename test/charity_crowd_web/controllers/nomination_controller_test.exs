defmodule CharityCrowdWeb.NominationControllerTest do
  use CharityCrowdWeb.ConnCase
  import CharityCrowd.Fixtures

  @create_attrs %{name: "some name", pitch: "some pitch"}
  @update_attrs %{name: "some updated name", pitch: "some updated pitch"}
  @invalid_attrs %{name: nil, pitch: nil}

  describe "index" do
    test "lists all nominations", %{conn: conn} do
      conn = get(conn, Routes.nomination_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Nominations"
    end
  end

  describe "new nomination" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.nomination_path(conn, :new))
      assert html_response(conn, 200) =~ "New Nomination"
    end
  end

  describe "create nomination" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.nomination_path(conn, :create), nomination: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.nomination_path(conn, :show, id)

      conn = get(conn, Routes.nomination_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Nomination"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.nomination_path(conn, :create), nomination: @invalid_attrs)
      assert html_response(conn, 422) =~ "New Nomination"
    end
  end

  describe "edit nomination" do
    setup [:create_nomination]

    test "renders form for editing chosen nomination", %{conn: conn, nomination: nomination} do
      conn = get(conn, Routes.nomination_path(conn, :edit, nomination))
      assert html_response(conn, 200) =~ "Edit Nomination"
    end
  end

  describe "update nomination" do
    setup [:create_nomination]

    test "redirects when data is valid", %{conn: conn, nomination: nomination} do
      conn = put(conn, Routes.nomination_path(conn, :update, nomination), nomination: @update_attrs)
      assert redirected_to(conn) == Routes.nomination_path(conn, :show, nomination)

      conn = get(conn, Routes.nomination_path(conn, :show, nomination))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, nomination: nomination} do
      conn = put(conn, Routes.nomination_path(conn, :update, nomination), nomination: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Nomination"
    end
  end

  describe "delete nomination" do
    setup [:create_nomination]

    test "deletes chosen nomination", %{conn: conn, nomination: nomination} do
      conn = delete(conn, Routes.nomination_path(conn, :delete, nomination))
      assert redirected_to(conn) == Routes.nomination_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.nomination_path(conn, :show, nomination))
      end
    end
  end

  defp create_nomination(_) do
    member = fixture(:member)
    nomination = fixture(:nomination, member: member)
    %{nomination: nomination}
  end
end
