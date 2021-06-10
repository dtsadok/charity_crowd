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
    #TODO: Replace this with current_user
    nomination_params = Map.put(nomination_params, "member_id", -1)

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
    changeset = Grants.change_nomination(nomination)
    render(conn, "edit.html", nomination: nomination, changeset: changeset)
  end

  def update(conn, %{"id" => id, "nomination" => nomination_params}) do
    nomination = Grants.get_nomination!(id)

    case Grants.update_nomination(nomination, nomination_params) do
      {:ok, nomination} ->
        conn
        |> put_flash(:info, "Nomination updated successfully.")
        |> redirect(to: Routes.nomination_path(conn, :show, nomination))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", nomination: nomination, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    nomination = Grants.get_nomination!(id)
    {:ok, _nomination} = Grants.delete_nomination(nomination)

    conn
    |> put_flash(:info, "Nomination deleted successfully.")
    |> redirect(to: Routes.nomination_path(conn, :index))
  end
end
