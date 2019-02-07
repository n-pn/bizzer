defmodule BizzerWeb.Public.SearchController do
  use BizzerWeb, :controller

  alias BizzerWeb.{FetchResource}

  plug FetchResource, :grouping when action in [:grouping, :location]
  plug FetchResource, :location when action in [:grouping, :location]
  plug FetchResource, :adentry when action in [:adentry, :adentry_slug]

  alias Bizzer.{
    GroupingQuery,
    LocationQuery,
    PropkeyQuery,
    PropvalQuery,
    AdentryQuery
  }

  def front(conn, _params) do
    groupings = GroupingQuery.fetch()
    render(conn, "front.html", groupings: groupings)
  end

  def grouping(conn, _params) do
    grouping = conn.assigns.grouping

    conn
    |> assign(:page_type, :grouping)
    |> assign(:page_title, grouping.name <> " tại Toàn quốc")
    |> _render_multi
  end

  def location(conn, _params) do
    grouping = conn.assigns.grouping
    location = conn.assigns.location

    conn
    |> assign(:page_type, :location)
    |> assign(:page_title, grouping.name <> " tại " <> location.name)
    |> _render_multi
  end

  defp _render_multi(conn) do
    import Bizzer.FormatUtil

    page = Map.get(conn.params, "page", "1") |> parse_int()
    page = if page > 1, do: page, else: 1

    locations = LocationQuery.fetch()
    groupings = GroupingQuery.fetch()

    grouping_id = if grouping = conn.assigns.grouping, do: grouping.id, else: 0
    location_id = if location = conn.assigns.location, do: location.id, else: 0

    propvals =
      for {key, val} <- conn.params do
        propkey = PropkeyQuery.find(grouping_id, key)
        if propkey, do: PropvalQuery.find(propkey.id, val), else: nil
      end
      |> Stream.reject(&is_nil(&1))

    propval_ids = propvals |> Enum.map(& &1.id)
    propval_map = propvals |> Enum.map(&{&1.propkey_id, &1}) |> Enum.into(%{})

    propkeys =
      for propkey <- PropkeyQuery.list(grouping_id: grouping_id, preload: true) do
        {propkey, propval_map[propkey.id]}
      end

    keyword = Map.get(conn.params, "tu-khoa")

    price_min = Map.get(conn.params, "price_min") |> parse_int(nil)
    price_max = Map.get(conn.params, "price_max") |> parse_int(nil)

    user_type =
      case Map.get(conn.params, "nguoi-ban") do
        "ca-nhan" -> :"ca-nhan"
        "ban-chuyen" -> :"ban-chuyen"
        _ -> nil
      end

    user_need =
      case Map.get(conn.params, "dang-tin") do
        "can-ban" -> :"can-ban"
        "can-mua" -> :"can-mua"
        _ -> nil
      end

    sort_by =
      case Map.get(conn.params, "sort_by") do
        "price" -> :price
        _ -> :time
      end

    query = [
      page: page,
      status: :accepted,
      grouping_id: grouping_id,
      location_id: location_id,
      propval_ids: propval_ids,
      keyword: keyword,
      price_min: price_min,
      price_max: price_max,
      user_type: user_type,
      user_need: user_need,
      sort_by: sort_by
    ]

    adentries = AdentryQuery.fetch(query)

    categories =
      if grouping_id == 0 do
        {:parent, groupings}
      else
        grouping = conn.assigns.grouping
        parent_id = if grouping.type == :parent, do: grouping.id, else: grouping.parent_id

        parent = groupings |> Enum.find(&(&1.id == parent_id))
        {:children, parent, parent.children}
      end

    conn
    |> assign(:query, query)
    |> assign(:locations, locations)
    |> assign(:groupings, groupings)
    |> assign(:categories, categories)
    |> assign(:propkeys, propkeys)
    |> assign(:adentries, adentries)
    |> render("query.html")
  end

  def adentry(conn, _) do
    _render_adentry(conn)
  end

  def adentry_slug(conn, _) do
    _render_adentry(conn)
  end

  defp _render_adentry(conn) do
    adentry = conn.assigns.adentry

    conn
    |> assign(:page_type, :adentry)
    |> assign(:page_title, adentry.subject)
    |> assign(:page_desc, adentry.details |> String.slice(0..1000))
    |> assign(:page_image, adentry.image_urls |> Enum.at(0))
    |> assign(:page_url, current_url(conn))
    |> render("adentry.html")
  end
end
