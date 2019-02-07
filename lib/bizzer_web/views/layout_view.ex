defmodule BizzerWeb.LayoutView do
  use BizzerWeb, :view

  def page_title(%{assigns: %{page_title: title}}), do: title <> " - Bizzer Store"
  def page_title(_), do: "Bizzer Store - Rao vặt tổng hợp"

  def page_image(%{assigns: %{page_image: image}}) do
    if String.starts_with?(image, "/"),
      do: gen_image_url(image),
      else: image
  end

  def page_image(_), do: nil

  @desc "Tổng hợp thông tin rao vặt về bất động sản, xe cộ, đồ điện tử và rất nhiều loại mặt hàng khác"
  def page_desc(conn), do: conn.assigns[:page_desc] || @desc
  def page_type(conn), do: conn.assigns[:page_type] || "website"
  def page_url(conn), do: conn.assigns[:page_url]

  def user_role(conn), do: if(logged_in?(conn), do: current_user(conn).role, else: :guest)
end
