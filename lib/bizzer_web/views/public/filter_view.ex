defmodule BizzerWeb.Public.FilterView do
  use BizzerWeb, :view

  def filter_path(conn, opts \\ []) do
    grouping = conn.assigns.grouping
    location = conn.assigns.location

    if location.id == 0 do
      public_search_path(conn, :grouping, grouping.slug, opts)
    else
      public_search_path(conn, :location, grouping.slug, location.slug, opts)
    end
  end
end
