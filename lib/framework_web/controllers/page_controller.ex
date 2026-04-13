defmodule FrameworkWeb.PageController do
  use FrameworkWeb, :controller

  def index(conn, _params) do
    case get_session(conn, "user_token") do
      nil -> render(conn, :index)          # Not logged in
      _token -> redirect(conn, to: PhoenixKit.Utils.Routes.path("/dashboard"))  # Logged in
    end
  end
end
