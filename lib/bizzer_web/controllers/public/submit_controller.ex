defmodule BizzerWeb.Public.SubmitController do
  use BizzerWeb, :controller

  alias BizzerWeb.{AccessControl, FetchResource, GuardResource}

  plug FetchResource, :adentry when action in [:show, :edit, :update, :delete]
  plug AccessControl, :login when action in [:new, :create, :edit, :update, :delete]
  plug GuardResource, :adentry when action in [:edit, :update, :delete]

  alias Bizzer.{
    LocationQuery,
    GroupingQuery,
    PropkeyQuery,
    AdentryAction
  }

  def new(conn, params) do
    chset = AdentryAction.change(params)

    conn
    |> assign(:fresh, true)
    |> _render(chset, "new.html")
  end

  def create(conn, %{"submit" => params}) do
    user = conn.assigns.current_user
    params = Map.put(params, "user_id", user.id)

    case AdentryAction.insert(params, :manual) do
      {:error, chset} ->
        _render(conn, chset, "new.html")

      {:ok, adentry} ->
        redirect(
          conn,
          to:
            public_search_path(
              conn,
              :adentry,
              adentry.grouping_slug,
              adentry.location_slug,
              adentry.slug <> "-" <> adentry.subject_slug
            )
        )
    end
  end

  def edit(conn, params) do
    adentry = conn.assigns.adentry
    chset = AdentryAction.change(params, adentry)
    _render(conn, chset, "edit.html")
  end

  def update(conn, %{"submit" => params}) do
    adentry = conn.assigns.adentry

    case AdentryAction.update(adentry, params) do
      {:error, chset} ->
        _render(conn, chset, "edit.html")

      {:ok, adentry} ->
        redirect(conn,
          to:
            public_search_path(
              conn,
              :adentry,
              adentry.grouping_slug,
              adentry.location_slug,
              adentry.slug <> "-" <> adentry.subject_slug
            )
        )
    end
  end

  def delete(conn) do
    adentry = conn.assigns.adentry
    AdentryAction.update(adentry, %{status: :deleted}, :review)
    redirect(conn, to: "/")
  end

  def stop(conn) do
    adentry = conn.assigns.adentry
    AdentryAction.update(adentry, %{status: :stopped}, :review)
    redirect(conn, to: "/")
  end

  defp _render(conn, chset, view) do
    groupings = GroupingQuery.fetch()
    locations = LocationQuery.fetch()

    grouping_slug = Ecto.Changeset.get_field(chset, :grouping_slug)
    grouping = GroupingQuery.find(grouping_slug)
    propval_ids = Ecto.Changeset.get_field(chset, :propval_ids)
    properties = PropkeyQuery.for_submit(grouping, propval_ids)

    conn
    |> assign(:groupings, groupings)
    |> assign(:locations, locations)
    |> assign(:properties, properties)
    |> assign(:chset, chset)
    |> render(view)
  end
end
