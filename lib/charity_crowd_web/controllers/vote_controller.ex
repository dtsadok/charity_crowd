defmodule CharityCrowdWeb.VoteController do
  use CharityCrowdWeb, :controller
  alias CharityCrowd.Grants

  def create(conn, %{"vote" => vote_params}) do
    #how many votes do we have left?

    current_member = conn.assigns[:current_member]

    #prevent voting on own nomination
    nomination_id = vote_params["nomination_id"]
    nomination = Grants.get_nomination!(nomination_id)

    if current_member.id == nomination.member_id do
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(422, "Cannot vote on own nomination")
    else
      #TODO: DB Transaction
      case Grants.create_vote(vote_params) do
        {:ok, _vote} ->
          #TODO: Globalize
          Calendar.Date.today!("America/New_York")
          |> Grants.list_nominations
          |> Grants.calculate_percentages!

          conn
          |> put_flash(:info, "Vote counted successfully.")
          |> redirect(to: Routes.nomination_path(conn, :index))

        {:error, %Ecto.Changeset{} = _changeset} ->
          conn
          |> put_resp_content_type("text/html")
          |> send_resp(422, "Vote is invalid")

        {:error, msg} ->
          conn
          |> put_resp_content_type("text/html")
          |> send_resp(422, msg)
      end
    end
  end
end
