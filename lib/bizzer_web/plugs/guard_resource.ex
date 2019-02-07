defmodule BizzerWeb.GuardResource do
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, :adentry) do
    user = conn.assigns.current_user
    adentry = conn.assigns.adentry

    if user.role in [:editor, :admin] or user.id == adentry.user_id do
      conn
    else
      conn |> redirect(to: "/")
    end
  end

  def call(conn, _), do: conn
end
