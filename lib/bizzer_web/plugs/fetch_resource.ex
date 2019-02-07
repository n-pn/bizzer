defmodule BizzerWeb.FetchResource do
  import Plug.Conn
  import Phoenix.Controller

  alias Bizzer.{AdentryQuery, AdimageQuery, GroupingQuery, LocationQuery, PropvalQuery}

  def init(opts), do: opts

  def call(conn, :adentry) do
    slug = conn.params["adentry"] |> String.split("-", trim: true) |> Enum.at(0)

    case AdentryQuery.find(slug) do
      nil ->
        render_404(conn, "Tin rao vặt không tồn tại hoặc đã bị xóa")

      adentry ->
        adimages = AdimageQuery.glob(adentry.image_ids)
        properties = PropvalQuery.glob(adentry.propval_ids)

        conn
        |> assign(:adentry, adentry)
        |> assign(:adimages, adimages)
        |> assign(:properties, properties)
    end
  end

  def call(conn, :adimage) do
    case AdimageQuery.get(conn.params["adimage"]) do
      nil -> render_404(conn, "File ảnh không tồn tại hoặc đã bị xóa")
      adimage -> assign(conn, :adimage, adimage)
    end
  end

  def call(conn, :grouping) do
    case GroupingQuery.find(conn.params["grouping"] || "tat-ca-chuyen-muc") do
      nil -> render_404(conn, "Chuyên mục không tồn tại")
      grouping -> assign(conn, :grouping, grouping)
    end
  end

  def call(conn, :location) do
    case LocationQuery.find(conn.params["location"] || "toan-quoc") do
      nil -> render_404(conn, "Khu vực không tồn tại")
      location -> assign(conn, :location, location)
    end
  end

  def render_404(conn, message) do
    conn
    |> render(BizzerWeb.ErrorView, "404.html", message: message)
    |> halt
  end
end
