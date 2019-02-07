defmodule BizzerWeb.Public.WizardController do
  use BizzerWeb, :controller

  alias Bizzer.{GroupingQuery, PropkeyQuery}

  def properties(conn, %{"grouping" => grouping}) do
    grouping = GroupingQuery.find(grouping)

    properties =
      PropkeyQuery.list(grouping_id: grouping.id, preload: true) |> Enum.map(&{&1, nil})

    conn
    |> put_layout(false)
    |> render("_properties.html", properties: properties, index: 9)
  end
end
