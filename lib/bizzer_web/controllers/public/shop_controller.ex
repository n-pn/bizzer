defmodule BizzerWeb.Public.ShopController do
  use BizzerWeb, :controller

  alias Bizzer.{ShopAction, ShopQuery, AdentryQuery}

  plug BizzerWeb.AccessControl,
       :login when action in [:self, :new, :create, :edit, :update, :activate]

  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    shops = ShopQuery.fetch(page: page)

    render(conn, "index.html", page: page, shops: shops)
  end

  def show(conn, %{"shop" => slug}) do
    case ShopQuery.find(slug) do
      nil ->
        conn |> render(BizzerWeb.ErrorView, "404.html", message: "Shop not found!")

      shop ->
        _render_show(conn, shop)
    end
  end

  def self(conn, _params) do
    user = conn.assigns.current_user

    case ShopQuery.find_by_user_id(user.id) do
      nil ->
        redirect(conn, to: public_shop_path(conn, :new))

      shop ->
        _render_show(conn, shop)
    end
  end

  @images [
    "cac-loai-rao-vat-khac.jpeg",
    "mua-ban-nha-dat.jpeg",
    "thue-nha-dat.jpeg",
    "mua-ban-xe.jpeg",
    "mua-ban-do-dien-tu.jpeg",
    "thoi-trang-lam-dep.jpeg",
    "noi-ngoai-that-do-gia-dung.jpeg",
    "do-suu-tam-phim-sach.jpeg"
  ]

  def _render_show(conn, shop) do
    page = Bizzer.FormatUtil.parse_int(conn.params["page"], 0)

    adentries =
      case shop.status do
        :pending ->
          for _ <- 1..10 do
            %Bizzer.Adentry{
              image_urls: ["/img/groupings/" <> Enum.random(@images)],
              subject: "Lorem ipsum dolor sit amet, consectetur adipisicing elit.",
              price_print: "#{:rand.uniform(100)}.000.000 đ",
              grouping_name: "Tất cả chuyên mục",
              grouping_slug: "tat-ca-chuyen-muc",
              location_name: "Toàn quốc",
              location_slug: "toan-quoc",
              slug: "fake-entry",
              subject_slug: "lorem-ipsum-dolor-sit-amet"
            }
          end

        _ ->
          AdentryQuery.fetch(page: page, shop_id: shop.id)
      end

    render(conn, "show.html", shop: shop, adentries: adentries, page: page)
  end

  def new(conn, _params) do
    user = conn.assigns.current_user

    case ShopQuery.find_by_user_id(user.id) do
      nil ->
        user_name = user.name || user.slug
        user_slug = user.name || user.slug

        chset =
          ShopAction.change(%{
            name: "Chuyên trang " <> user_name,
            slug: ("chuyen-trang-" <> user_slug) |> Bizzer.FormatUtil.slugify(),
            address: user.address,
            phone: user.phone
          })

        render(conn, "new.html", chset: chset)

      _shop ->
        redirect(conn, to: public_shop_path(conn, :edit))
    end
  end

  def create(conn, %{"shop" => shop}) do
    user = conn.assigns.current_user
    shop = Map.put(shop, "user_id", user.id)

    case ShopAction.insert(shop, :manual) do
      {:ok, _} -> redirect(conn, to: public_shop_path(conn, :self))
      {:error, chset} -> render(conn, "new.html", chset: chset)
    end
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user
    shop = ShopQuery.find_by_user_id(user.id)

    chset = ShopAction.change(%{}, shop)
    render(conn, "edit.html", chset: chset)
  end

  def update(conn, %{"shop" => shop_param}) do
    user = conn.assigns.current_user
    shop = ShopQuery.find_by_user_id(user.id)

    case ShopAction.update(shop, shop_param) do
      {:ok, _} -> redirect(conn, to: public_shop_path(conn, :self))
      {:error, chset} -> render(conn, "edit.html", chset: chset)
    end
  end

  def activate(conn, _params) do
    user = conn.assigns.current_user

    case ShopQuery.find_by_user_id(user.id) do
      nil ->
        redirect(conn, to: public_shop_path(conn, :new))

      shop ->
        shop = Ecto.Changeset.change(shop, status: :running)
        Bizzer.Repo.update(shop)

        redirect(conn, to: public_shop_path(conn, :self))
    end
  end
end
