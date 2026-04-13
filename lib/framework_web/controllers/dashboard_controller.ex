defmodule FrameworkWeb.DashboardController do
  use FrameworkWeb, :controller

  def sidebar(conn, %{"token" => token, "show_sidebar" => state}) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:show_sidebar, state)
    |> redirect(to: PhoenixKit.url_prefix())
  end
end
