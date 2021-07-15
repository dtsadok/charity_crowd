defmodule CharityCrowdWeb.NominationController do
  use CharityCrowdWeb, :controller

  alias CharityCrowd.Grants
  alias CharityCrowd.Grants.Nomination
  alias CharityCrowd.Endowment

  def index(conn, params) do
    current_member = conn.assigns[:current_member]

    #TODO: Globalize
    today = Calendar.Date.today!("America/New_York")
    year = params["year"] || today.year
    month = params["month"] || today.month
    day = params["day"] || today.day

    {year, _} = Integer.parse("#{year}")
    {month, _} = Integer.parse("#{month}")
    {day, _} = Integer.parse("#{day}")

    {:ok, date} = Date.new(year, month, day)

    archived = date < Endowment.get_last_balance!().date

    balance = Endowment.get_prev_balance_for(date)
    grant_budget_cents = Endowment.get_grant_budget_cents(date)

    #used to link to previous/next voting period
    day_before = balance && Calendar.Date.prev_day!(balance.date)
    prev_balance = day_before && Endowment.get_prev_balance_for(day_before)
    day_after = balance && Calendar.Date.next_day!(balance.date)
    next_balance = day_after && Endowment.get_next_balance_for(day_after)

    nominations = Grants.list_nominations(date)

    render(conn, "index.html",
      current_member: current_member,
      date: date,
      balance_cents: (balance && balance.amount_cents) || 0,
      balance_date: balance && balance.date,
      grant_budget_cents: grant_budget_cents,
      archived: archived,
      prev_balance_date: prev_balance && prev_balance.date,
      next_balance_date: next_balance && next_balance.date,
      nominations: nominations)
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
