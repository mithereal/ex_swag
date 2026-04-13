defmodule FrameworkWeb.PageController do
  use FrameworkWeb, :controller

  def index(conn, _params) do
    case get_session(conn, "user_token") do
      # Not logged in
      nil -> render(conn, :index)
      # Logged in
      _token -> redirect(conn, to: PhoenixKit.Utils.Routes.path("/dashboard"))
    end
  end
end
