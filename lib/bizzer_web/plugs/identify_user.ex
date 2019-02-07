defmodule BizzerWeb.IdentifyUser do
  import Plug.Conn

  alias Bizzer.{AuthQuery, UserQuery}

  def init(opts), do: opts

  def call(conn, _opts) do
    token = _get_token(conn)

    case AuthQuery.find(token) do
      nil ->
        conn

      auth ->
        user = UserQuery.get(auth.user_id)
        conn |> assign(:current_user, user)
    end
  end

  defp _get_token(conn) do
    IO.inspect(get_req_header(conn, "auth_token"))

    case get_req_header(conn, "auth_token") do
      [] -> get_session(conn, :auth_token)
      [token] -> token
      _ -> nil
    end
  end

  def current_user(conn), do: conn.assigns[:current_user]
  def logged_in?(conn), do: !!current_user(conn)
end
