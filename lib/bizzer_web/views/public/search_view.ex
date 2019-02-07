defmodule BizzerWeb.Public.SearchView do
  use BizzerWeb, :view

  #   def is_active(a, b) when a == b, do: " _active"
  #   def is_active(_, _), do: ""

  #   def count_filter(conn), do: length(conn.assigns.query[:propval_ids])

  #   def first_image(nil), do: "/img/blank.jpg"
  #   def first_image([]), do: "/img/blank.jpg"
  #   def first_image(list), do: list |> Enum.at(0)

  def prev_url(conn) do
    page = conn.assigns[:query][:page]

    if page > 1 do
      query_path(conn, page: page - 1)
    else
      nil
    end
  end

  def next_url(conn) do
    page = conn.assigns[:query][:page]
    list = conn.assigns[:adentries]

    if length(list) == 12 do
      query_path(conn, page: page + 1)
    else
      nil
    end
  end

  def query_path(conn, opts \\ []) do
    query = conn.assigns.query

    opts = if query[:price_min] > -1, do: opts ++ ["gia-san": query[:price_min]], else: opts
    opts = if query[:price_max] > -1, do: opts ++ ["gia-tran": query[:price_max]], else: opts

    propkeys =
      for {param, value} <- conn.assigns.propkeys do
        if value, do: {String.to_atom(param.slug), value.slug}, else: nil
      end
      |> Enum.reject(&is_nil(&1))

    opts = opts ++ propkeys

    opts = if x = query[:keyword], do: opts ++ ["tu-khoa": x], else: opts
    opts = if x = query[:user_type], do: opts ++ ["nguoi-ban": x], else: opts
    opts = if x = query[:user_need], do: opts ++ ["dang-tin": x], else: opts

    filter_path(conn, opts)
  end

  def filter_path(conn, opts \\ []) do
    grouping = conn.assigns.grouping
    location = conn.assigns.location

    if location.id == 0 do
      public_search_path(conn, :grouping, grouping.slug, opts)
    else
      public_search_path(conn, :location, grouping.slug, location.slug, opts)
    end
  end

  #   def user_types, do: [{"Cá nhân", :"ca-nhan"}, {"Bán chuyên", :"ban-chuyen"}]
  #   def user_needs, do: [{"Cần bán", :"can-ban"}, {"Cần mua", :"can-mua"}]
end
