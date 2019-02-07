defmodule BizzerWeb.Public.SupportController do
  use BizzerWeb, :controller

  def about(conn, _) do
    render(conn, "about.html")
  end

  def terms(conn, _) do
    render(conn, "terms.html")
  end

  def policy(conn, _) do
    render(conn, "policy.html")
  end
end
