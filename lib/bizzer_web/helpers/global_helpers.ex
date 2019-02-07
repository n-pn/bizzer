defmodule BizzerWeb.GlobalHelpers do
  # import Plug.Conn

  def current_user(conn), do: conn.assigns[:current_user]

  def logged_in?(conn), do: !!current_user(conn)

  def return_url(conn), do: conn.params["next"] || "/"
end
