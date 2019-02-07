defmodule BizzerWeb.Public.NotificationController do
  use BizzerWeb, :controller

  alias Bizzer.NotificationQuery
  alias BizzerWeb.AccessControl

  plug AccessControl, :login

  def list(conn, _) do
    user = conn.assigns.current_user
    notifications = NotificationQuery.fetch(user.id)

    conn
    |> put_layout(false)
    |> render("_list.html", notifications: notifications)
  end
end
