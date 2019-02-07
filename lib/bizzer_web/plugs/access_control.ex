defmodule BizzerWeb.AccessControl do
  import Plug.Conn
  import Phoenix.Controller
  import BizzerWeb.Router.Helpers

  import BizzerWeb.IdentifyUser, only: [current_user: 1, logged_in?: 1]

  def init(opts), do: opts

  def call(conn, :guest) do
    if logged_in?(conn) do
      conn
      |> put_flash(:error, "Bạn đã đăng nhập")
      |> redirect(to: "/")
      |> halt
    else
      conn
    end
  end

  def call(conn, :login) do
    if !logged_in?(conn) do
      conn
      |> put_flash(:error, "Bạn chưa đăng nhập")
      |> redirect(to: public_auth_path(conn, :new, next: current_path(conn)))
      |> halt
    else
      conn
    end
  end

  def call(conn, role) when is_atom(role) do
    user = current_user(conn)

    if user && (user.role == role or user.role == :admin) do
      conn
    else
      conn
      |> put_flash(:error, "Quyền hạn không đủ")
      |> redirect(to: "/")
      |> halt
    end
  end

  def call(conn, roles) when is_list(roles) do
    user = current_user(conn)

    if user && user.role in roles do
      conn
    else
      conn
      |> put_flash(:error, "Không đúng phân loại người dùng")
      |> redirect(to: "/")
      |> halt
    end
  end
end
