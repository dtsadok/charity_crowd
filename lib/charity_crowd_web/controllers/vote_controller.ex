defmodule CharityCrowdWeb.VoteController do
  use CharityCrowdWeb, :controller

  alias CharityCrowd.Grants

  def create(conn, %{"vote" => vote_params}) do
    member_id = conn.assigns[:current_member].id
    case Grants.create_vote(Map.put(vote_params, "member_id", member_id)) do
      {:ok, vote} ->
        conn
        |> put_flash(:info, "Vote counted successfully.")
        |> redirect(to: Routes.nomination_path(conn, :show, vote.nomination_id))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(422, "Vote data invalid.")
    end
  end

  def delete(conn, %{"id" => id}) do
    vote = Grants.get_vote!(id)
    {:ok, _vote} = Grants.delete_vote(vote)

    conn
    |> put_flash(:info, "Vote withdrawn successfully.")
    |> redirect(to: Routes.nomination_path(conn, :index))
  end
end