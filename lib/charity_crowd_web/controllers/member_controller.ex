defmodule CharityCrowdWeb.MemberController do
  use CharityCrowdWeb, :controller

  alias CharityCrowd.Accounts
  alias CharityCrowd.Accounts.Member

  def index(conn, _params) do
    members = Accounts.list_members()
    render(conn, "index.html", members: members)
  end

  def new(conn, _params) do
    changeset = Accounts.change_member(%Member{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"member" => member_params, "invite_code" => code}) do
    try do
      #TODO: replace this check with plug(?)
      invite_code = Accounts.get_active_invite_code!(code)

      case Accounts.create_member(member_params) do
        {:ok, _member} ->
          Accounts.update_invite_code(invite_code, %{active: false})
          conn
          |> put_flash(:info, "Signed up successfully.")
          |> redirect(to: Routes.page_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> render("new.html", changeset: changeset)
      end
    rescue
      Ecto.NoResultsError ->
        changeset = Accounts.change_member(%Member{})
        conn
        |> put_status(422)
        |> put_flash(:info, "Invalid invite code.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)
    render(conn, "show.html", member: member)
  end

  def edit(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)
    changeset = Accounts.change_member(member)
    render(conn, "edit.html", member: member, changeset: changeset)
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Accounts.get_member!(id)

    case Accounts.update_member(member, member_params) do
      {:ok, member} ->
        conn
        |> put_flash(:info, "Member updated successfully.")
        |> redirect(to: Routes.member_path(conn, :show, member))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", member: member, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    member = Accounts.get_member!(id)
    {:ok, _member} = Accounts.delete_member(member)

    conn
    |> put_flash(:info, "Member deleted successfully.")
    |> redirect(to: Routes.member_path(conn, :index))
  end
end
