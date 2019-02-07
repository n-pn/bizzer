defmodule BizzerWeb.Admin.ExportController do
  use BizzerWeb, :controller

  alias Bizzer.{Repo, Adentry}

  def index(conn, %{"id" => id}) do
    item =
      Repo.get_by!(Adentry, origin_uid: id)
      |> Repo.preload([:user, :shop, :editor])

    json(conn, item)
  end
end
