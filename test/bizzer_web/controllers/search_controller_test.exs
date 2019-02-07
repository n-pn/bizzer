defmodule BizzerWeb.SearchControllerTest do
  use BizzerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Bizzer Store"
  end
end
