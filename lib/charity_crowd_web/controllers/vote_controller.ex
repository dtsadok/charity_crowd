defmodule CharityCrowdWeb.VoteController do
  use CharityCrowdWeb, :controller
  alias CharityCrowd.Grants
  alias CharityCrowd.Accounts

  def create(conn, %{"vote" => vote_params}) do
    current_member = conn.assigns[:current_member]

    #prevent voting on own nomination
    nomination_id = vote_params["nomination_id"]
    nomination = Grants.get_nomination!(nomination_id)

    cond do
      current_member.id == nomination.member_id ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(422, "Cannot vote on own nomination")

    #do we have any votes left?
    Accounts.votes_left(current_member) <= 0 ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(422, "No more votes for this voting period.")

    true ->
      #create new Ballot for this vote
      today = Calendar.Date.today!("America/New_York")
      {:ok, _ballot} = Accounts.create_ballot(current_member, today)

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
