defmodule BizzerWeb.Admin.AdentryController do
  use BizzerWeb, :controller

  alias Bizzer.{AdentryAction, AdentryQuery}
  alias BizzerWeb.{AccessControl, FetchResource}

  plug AccessControl, [:editor, :admin]
  plug AccessControl, :admin when action == :delete
  plug FetchResource, :adentry when action in [:show, :accept, :reject, :delete]

  def pick(conn, _) do
    case AdentryQuery.get_random_pending() do
      nil -> redirect(conn, to: admin_adentry_path(conn, :index))
      adentry -> redirect(conn, to: admin_adentry_path(conn, :show, adentry.slug))
    end
  end

  def show(conn, _) do
    render(conn, "show.html", page_url: current_url(conn))
  end

  def accept(conn, _param) do
    user = conn.assigns.current_user
    adentry = conn.assigns.adentry

    params = %{
      user_id: adentry.user_id,
      type: :accept_adentry,
      data: %{
        reviewer_id: user.id,
        reviewer_name: user.name || "Admin",
        adentry_id: adentry.id,
        adentry_subject: adentry.subject,
        adentry_url:
          public_search_path(
            conn,
            :adentry,
            adentry.grouping_slug,
            adentry.location_slug,
            adentry.slug <> "-" <> adentry.subject_slug
          )
      }
    }

    Bizzer.NotificationAction.insert(params)
    AdentryAction.update(adentry, %{status: :accepted, editor_id: user.id}, :review)

    redirect(conn, to: admin_adentry_path(conn, :pick))
  end

  def reject(conn, params) do
    user = conn.assigns.current_user
    adentry = conn.assigns.adentry

    params = %{
      user_id: adentry.user_id,
      type: :reject_adentry,
      data: %{
        reviewer_id: user.id,
        reviewer_name: user.name || "Admin",
        reason: params["reason"],
        adentry_id: adentry.id,
        adentry_subject: adentry.subject,
        adentry_url:
          public_search_path(
            conn,
            :adentry,
            adentry.grouping_slug,
            adentry.location_slug,
            adentry.slug <> "-" <> adentry.subject_slug
          )
      }
    }

    Bizzer.NotificationAction.insert(params)
    AdentryAction.update(adentry, %{status: :rejected, editor_id: user.id}, :review)

    redirect(conn, to: admin_adentry_path(conn, :pick))
  end

  def delete(conn, _) do
    user = conn.assigns.current_user
    adentry = conn.assigns.adentry
    AdentryAction.update(adentry, %{status: :deleted, editor_id: user.id}, :review)
    redirect(conn, to: admin_adentry_path(conn, :index))
  end

  def index(conn, params) do
    page = Bizzer.FormatUtil.parse_int(params["page"] || "1")

    status =
      case params["status"] do
        "accepted" -> :accepted
        "rejected" -> :rejected
        "stopped" -> :stopped
        _ -> :pending
      end

    opts = [page: page, status: status]

    adentries = AdentryQuery.fetch(opts)
    adentry_pending = AdentryQuery.count(status: :pending)
    adentry_accepted = AdentryQuery.count(status: :accepted)
    adentry_rejected = AdentryQuery.count(status: :rejected)
    adentry_deleted = AdentryQuery.count(status: :deleted)

    # AdentryAction.manage(adentry, %{status: :checking})
    render(
      conn,
      "index.html",
      adentries: adentries,
      adentry_pending: adentry_pending,
      adentry_accepted: adentry_accepted,
      adentry_rejected: adentry_rejected,
      adentry_deleted: adentry_deleted,
      opts: opts
    )
  end
end
