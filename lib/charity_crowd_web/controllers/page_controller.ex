defmodule CharityCrowdWeb.PageController do
  use CharityCrowdWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
