defmodule BizzerWeb.Admin.AdimageController do
  use BizzerWeb, :controller

  alias Bizzer.{AdimageAction, UserQuery, AdimageQuery}

  alias BizzerWeb.{AccessControl, FetchResource}

  plug AccessControl, [:worker, :admin]

  plug FetchResource, :adimage when action in [:show, :update, :delete]

  def index(conn, params) do
    page = Bizzer.FormatUtil.parse_int(params["page"] || "1")

    status =
      case params["status"] do
        "unedit" -> :unedit
        "unneed" -> :unneed
        _ -> "edited"
      end

    opts = [page: page, status: status]
    adimages = AdimageQuery.fetch(opts)

    render(
      conn,
      "index.html",
      opts: opts,
      adimages: adimages
    )
  end

  def stats(conn, _) do
    adimage_total = AdimageQuery.count()
    adimage_edited_total = AdimageQuery.count(status: :edited)

    this_hour = Bizzer.TimeUtil.this_hour()
    adimage_edited_this_hour = AdimageQuery.count(status: :edited, period: this_hour)

    this_day = Bizzer.TimeUtil.this_day()
    adimage_edited_this_day = AdimageQuery.count(status: :edited, period: this_day)

    this_week = Bizzer.TimeUtil.this_week()
    adimage_edited_this_week = AdimageQuery.count(status: :edited, period: this_week)

    this_month = Bizzer.TimeUtil.this_month()
    adimage_edited_this_month = AdimageQuery.count(status: :edited, period: this_month)

    workers = UserQuery.fetch(role: :worker)

    workers_edited_total =
      for worker <- workers do
        %{
          name: worker.name,
          count: AdimageQuery.count(status: :edited, worker: worker.id)
        }
      end

    workers_edited_this_hour =
      for worker <- workers do
        %{
          name: worker.name,
          count: AdimageQuery.count(status: :edited, period: this_hour, worker: worker.id)
        }
      end

    workers_edited_this_day =
      for worker <- workers do
        %{
          name: worker.name,
          count: AdimageQuery.count(status: :edited, period: this_day, worker: worker.id)
        }
      end

    workers_edited_this_week =
      for worker <- workers do
        %{
          name: worker.name,
          count: AdimageQuery.count(status: :edited, period: this_week, worker: worker.id)
        }
      end

    workers_edited_this_month =
      for worker <- workers do
        %{
          name: worker.name,
          count: AdimageQuery.count(status: :edited, period: this_month, worker: worker.id)
        }
      end

    render(
      conn,
      "stats.html",
      adimage_total: adimage_total,
      adimage_edited_total: adimage_edited_total,
      adimage_edited_this_day: adimage_edited_this_day,
      adimage_edited_this_hour: adimage_edited_this_hour,
      adimage_edited_this_week: adimage_edited_this_week,
      adimage_edited_this_month: adimage_edited_this_month,
      workers_edited_total: workers_edited_total,
      workers_edited_this_hour: workers_edited_this_hour,
      workers_edited_this_day: workers_edited_this_day,
      workers_edited_this_week: workers_edited_this_week,
      workers_edited_this_month: workers_edited_this_month
    )
  end

  def pick(conn, _) do
    adimage = AdimageQuery.get_random_unedit()

    if adimage do
      conn
      |> assign(:adimage, adimage)
      |> _render_image
    else
      redirect(conn, to: admin_adimage_path(conn, :index))
    end
  end

  def show(conn, _) do
    conn
    |> _render_image
  end

  defp _render_image(conn) do
    adimage = conn.assigns.adimage

    case AdimageAction.precache(adimage) do
      {:ok, adimage} ->
        conn |> render("show.html", adimage: adimage)

      {:error, _} ->
        conn |> redirect(to: admin_adimage_path(conn, :pick))
    end
  end

  def update(conn, %{"x_offset" => x_offset, "y_offset" => y_offset}) do
    user = conn.assigns.current_user
    adimage = conn.assigns.adimage

    attrs = %{
      worker_id: user.id,
      x_offset: x_offset,
      y_offset: y_offset
    }

    case AdimageAction.watermark(adimage, attrs) do
      {:ok, adimage} ->
        Task.start(fn -> Bizzer.AdentryAction.unlock(adimage) end)

        conn
        |> put_status(201)
        |> json(%{url: adimage.public_url})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{msg: inspect(reason)})
    end
  end

  def delete(conn, _params) do
    adimage = conn.assigns.adimage
    AdimageAction.delete(adimage.id)
    conn |> redirect(to: admin_adimage_path(conn, :pick))
  end
end
