defmodule BizzerWeb.Public.AuthController do
  use BizzerWeb, :controller

  alias Bizzer.{AuthAction, AuthQuery}
  alias BizzerWeb.AccessControl

  plug AccessControl, :guest when action != :destroy
  plug AccessControl, :login when action == :destroy

  def new(conn, params) do
    chset = AuthAction.change(params)
    render(conn, :new, chset: chset)
  end

  def create(conn, %{"user" => params}) do
    case AuthAction.insert(params, :login) do
      {:ok, auth} ->
        conn
        |> put_session(:auth_token, auth.token)
        |> redirect(to: return_url(conn))

      {:error, chset} ->
        render(conn, :new, chset: chset)
    end
  end

  def destroy(conn, _param) do
    case AuthQuery.find(get_session(conn, :auth_token)) do
      nil -> nil
      auth -> AuthAction.delete(auth)
    end

    conn
    |> put_session(:auth_token, nil)
    |> redirect(to: return_url(conn))
  end
end
