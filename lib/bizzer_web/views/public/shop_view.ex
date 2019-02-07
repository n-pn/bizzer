defmodule BizzerWeb.Public.ShopView do
  use BizzerWeb, :view

  def prev_url(conn) do
    page = conn.assigns[:page]
    tab = conn.assigns[:tab]

    action = conn.assigns[:current_action]

    if page > 1 do
      if action == :shop do
        shop = conn.assigns[:shop]
        public_shop_path(conn, :show, shop.slug, tab: tab, page: page - 1)
      else
        public_shop_path(conn, :self, tab: tab, page: page - 1)
      end
    else
      nil
    end
  end

  def next_url(conn) do
    page = conn.assigns[:page]
    tab = conn.assigns[:tab]
    list = conn.assigns[:adentries]

    action = conn.assigns[:current_action]

    if length(list) == 12 do
      if action == :shop do
        shop = conn.assigns[:shop]
        public_shop_path(conn, :show, shop.slug, tab: tab, page: page - 1)
      else
        public_shop_path(conn, :self, tab: tab, page: page + 1)
      end
    else
      nil
    end
  end
end
