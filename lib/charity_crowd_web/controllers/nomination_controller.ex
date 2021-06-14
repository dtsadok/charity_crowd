defmodule CharityCrowdWeb.NominationController do
  use CharityCrowdWeb, :controller

  alias CharityCrowd.Grants
  alias CharityCrowd.Grants.Nomination

  def index(conn, _params) do
    nominations = Grants.list_nominations()
    render(conn, "index.html", nominations: nominations)
  end

  def new(conn, _params) do
    changeset = Grants.change_nomination(%Nomination{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"nomination" => nomination_params}) do
    current_member = conn.assigns.current_member
    nomination_params = Map.put(nomination_params, "member_id", current_member.id)

    case Grants.create_nomination(nomination_params) do
      {:ok, nomination} ->
        conn
        |> put_flash(:info, "Nomination created successfully.")
        |> redirect(to: Routes.nomination_path(conn, :show, nomination))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    nomination = Grants.get_nomination!(id)
    render(conn, "show.html", nomination: nomination)
  end

  def edit(conn, %{"id" => id}) do
    nomination = Grants.get_nomination!(id)

    if nomination.member_id == conn.assigns.current_member.id do
      changeset = Grants.change_nomination(nomination)
      render(conn, "edit.html", nomination: nomination, changeset: changeset)
    else
      conn
        |> put_resp_content_type("text/html")
        |> send_resp(401, "Access denied.")
    end
  end

  def update(conn, %{"id" => id, "nomination" => nomination_params}) do
    nomination = Grants.get_nomination!(id)

    if nomination.member_id == conn.assigns.current_member.id do
      case Grants.update_nomination(nomination, nomination_params) do
        {:ok, nomination} ->
          conn
            |> put_flash(:info, "Nomination updated successfully.")
            |> redirect(to: Routes.nomination_path(conn, :show, nomination))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", nomination: nomination, changeset: changeset)
      end
    else
      conn
        |> put_resp_content_type("text/html")
        |> send_resp(401, "Access denied.")
    end
  end

  def delete(conn, %{"id" => id}) do
    nomination = Grants.get_nomination!(id)
    if nomination.member_id == conn.assigns.current_member.id do
      {:ok, _nomination} = Grants.delete_nomination(nomination)

      conn
        |> put_flash(:info, "Nomination deleted successfully.")
        |> redirect(to: Routes.nomination_path(conn, :index))
    else
      conn
        |> put_resp_content_type("text/html")
        |> send_resp(401, "Access denied.")
    end
  end
end
