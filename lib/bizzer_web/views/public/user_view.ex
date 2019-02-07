defmodule BizzerWeb.Public.UserView do
  use BizzerWeb, :view

  def prev_url(conn) do
    page = conn.assigns[:page]
    tab = conn.assigns[:tab]

    if page > 1 do
      if user = conn.assigns[:user] do
        public_user_path(conn, :show, user.slug, tab: tab, page: page - 1)
      else
        public_user_path(conn, :self, tab: tab, page: page - 1)
      end
    else
      nil
    end
  end

  def next_url(conn) do
    page = conn.assigns[:page]
    tab = conn.assigns[:tab]
    list = conn.assigns[:adentries]

    if length(list) == 12 do
      if user = conn.assigns[:user] do
        public_user_path(conn, :show, user.slug, tab: tab, page: page - 1)
      else
        public_user_path(conn, :self, tab: tab, page: page + 1)
      end
    else
      nil
    end
  end
end
