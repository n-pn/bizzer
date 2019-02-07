defmodule BizzerWeb.Public.UserController do
  use BizzerWeb, :controller

  alias Bizzer.{UserAction, UserQuery, AuthAction, AdentryQuery}

  plug BizzerWeb.AccessControl, :login when action in [:self, :edit, :update]

  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    users = UserQuery.fetch(page: page)

    render(conn, "index.html", page: page, users: users)
  end

  def show(conn, %{"user" => slug} = params) do
    case UserQuery.find(slug) do
      nil ->
        conn |> render(BizzerWeb.ErrorView, "404.html", message: "User not found!")

      user ->
        tab = params |> Map.get("tab", "dang-ban")
        page = params |> Map.get("page", "1") |> Bizzer.FormatUtil.parse_int()

        status =
          case tab do
            "da-ngung" -> :stopped
            _ -> :accepted
          end

        query = [user_id: user.id, page: page - 1, status: status]

        adentries = AdentryQuery.fetch(query)

        render(conn, "show.html", user: user, tab: tab, page: page, adentries: adentries)
    end
  end

  plug BizzerWeb.AccessControl, :login when action == :self

  def self(conn, params) do
    user = conn.assigns.current_user

    tab = params |> Map.get("tab", "doi-duyet")
    page = params |> Map.get("page", "1") |> Bizzer.FormatUtil.parse_int()

    status =
      case tab do
        "bi-tu-choi" -> :rejected
        "dang-chay" -> :accepted
        "da-ngung" -> :stopped
        "da-bi-xoa" -> :deleted
        _ -> :pending
      end

    query = [user_id: user.id, page: page - 1, status: status]

    adentries = AdentryQuery.fetch(query)

    render(conn, "self.html", user: user, tab: tab, page: page, adentries: adentries)
  end

  def new(conn, params) do
    chset = UserAction.change(params)
    render(conn, :new, chset: chset)
  end

  def create(conn, %{"user" => params}) do
    case UserAction.insert(params, :signup) do
      {:ok, user} ->
        {:ok, auth} = AuthAction.insert(%{user_id: user.id}, :signup)

        conn
        |> put_session(:auth_token, auth.token)
        |> redirect(to: return_url(conn))

      {:error, chset} ->
        render(conn, :new, chset: chset)
    end
  end

  def edit_profile(conn, params) do
    user = current_user(conn)
    chset = UserAction.change(params, user)
    render(conn, :edit_profile, chset: chset)
  end

  def update_profile(conn, %{"user" => params}) do
    user = current_user(conn)

    case UserAction.update(user, params, :profile) do
      {:ok, _user} ->
        conn
        |> redirect(to: public_user_path(conn, :self))

      {:error, chset} ->
        render(conn, :edit_profile, chset: chset)
    end
  end

  def edit_password(conn, params) do
    chset = UserAction.change(params)
    render(conn, :edit_password, chset: chset)
  end

  def update_password(conn, %{"user" => params}) do
    user = current_user(conn)

    case UserAction.update(user, params, :password) do
      {:ok, _user} ->
        conn
        |> redirect(to: public_user_path(conn, :self))

      {:error, chset} ->
        render(conn, :edit_password, chset: chset)
    end
  end
end
