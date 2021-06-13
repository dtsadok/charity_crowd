defmodule CharityCrowdWeb.SessionController do
  use CharityCrowdWeb, :controller

  alias CharityCrowd.Accounts

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate(email, password) do
      {:ok, member} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:member_id, member.id)
        |> configure_session(renew: true)
        |> redirect(to: "/")
      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Bad email/password combination")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
