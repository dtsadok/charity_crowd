defmodule CharityCrowdWeb.Router do
  use CharityCrowdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  #authenticated routes have to come first.  Why?  Because otherwise /foo/new maps to :show, not :new
  scope "/", CharityCrowdWeb do
    pipe_through [:browser, :authenticate]
    scope "/members" do
      get "/change_password", MemberController, :show_change_password_page
      post "/change_password", MemberController, :change_password
    end

    scope "/grants" do
      resources "/nominations", NominationController, except: [:index, :show]
      resources "/votes", VoteController, only: [:create, :delete]
    end
  end

  scope "/", CharityCrowdWeb do
    pipe_through [:browser, :get_current_member]

    get "/", PageController, :index

    resources "/sessions", SessionController, only: [:new, :create, :delete],
                                              singleton: true
    resources "/members", MemberController, only: [:new, :create]

    scope "/grants" do
      get "/nominations/:year/:month/:day", NominationController, :index
      resources "/nominations", NominationController, only: [:index, :show]
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", CharityCrowdWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CharityCrowdWeb.Telemetry
    end
  end

  defp authenticate(conn, _) do
    case get_session(conn, :member_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/sessions/new")
        |> halt()
      member_id ->
        assign(conn, :current_member, CharityCrowd.Accounts.get_member!(member_id))
    end
  end

  defp get_current_member(conn, _) do
    case get_session(conn, :member_id) do
      nil -> assign(conn, :current_member, nil)
      member_id ->
        assign(conn, :current_member, CharityCrowd.Accounts.get_member!(member_id))
    end
  end
end
