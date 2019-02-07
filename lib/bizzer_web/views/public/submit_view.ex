defmodule BizzerWeb.Public.SubmitView do
  use BizzerWeb, :view

  #   def onchild(%{type: type}, child) when type == child, do: " _onchild"
  #   def onchild(_, _), do: ""

  #   def isactive(%{id: id}, target) when id == target, do: " _active"
  #   def isactive(_, _), do: ""

  #   def isactivechild(%{parent_id: id}, target) when id == target, do: " _active"
  #   def isactivechild(_, _), do: ""

  #   def image_count(adentry) do
  #     images = adentry.image_urls || []
  #     length(images)
  #   end

  #   def first_image(adentry) do
  #     images = adentry.image_urls || []

  #     if length(images) == 0 do
  #       "/img/blank.jpg"
  #     else
  #       images |> Enum.at(0)
  #     end
  #   end

  #   def pretty_price(adentry) do
  #     CurrencyFormatter.format(adentry.price, :vnd)
  #   end

  #   @minute 60
  #   @hour @minute * 60
  #   @day @hour * 24

  #   def pretty_time(adentry) do
  #     diff = Bizzer.TimeUtil.time_diff(adentry.updated_at, :past)

  #     cond do
  #       diff < @minute -> "#{diff} giây trước"
  #       diff < @hour -> "#{div(diff, @minute)} phút trước"
  #       diff < @day -> "#{div(diff, @hour)} giờ trước"
  #       true -> "#{div(diff, @day)} ngày trước"
  #     end
  #   end

  #   def content_html(nil), do: ""

  #   def content_html(details) do
  #     details
  #     |> String.split("\n")
  #     |> Enum.map(&content_tag(:p, &1))
  #   end

  #   def is_empty(nil), do: " _empty"
  #   def is_empty(_), do: ""

  #   def is_active(a, b) when a != b, do: ""
  #   def is_active(_), do: " _active"

  #   def on_child(:nested, %{type: :child}), do: " _child"
  #   def on_child(_, _), do: ""

  #   def extract_error(form, field) do
  #     form.errors[field]
  #     |> elem(0)
  #   end

  #   import Ecto.Changeset

  #   def get_value(chset, :images) do
  #     chset
  #     |> get_value(:image_ids)
  #     |> Bizzer.AdimageQuery.glob()
  #   end

  #   def get_value(chset, field), do: get_field(chset, field)

  #   def get_print(chset, :user_type) do
  #     case get_field(chset, :user_type) do
  #       nil -> nil
  #       :"ca-nhan" -> "Cá nhân"
  #       :"ban-chuyen" -> "Bán chuyên"
  #     end
  #   end

  #   def get_print(chset, :user_need) do
  #     case get_field(chset, :user_need) do
  #       nil -> nil
  #       :"can-ban" -> "Cần bán/Cho thuê"
  #       :"can-mua" -> "Cần mua/Muốn thuê"
  #     end
  #   end

  #   def get_print(chset, :subject), do: get_field(chset, :subject)
  #   def get_print(chset, :details), do: raw_html(get_field(chset, :details_html))
  #   def get_print(chset, :payment), do: raw_html(get_field(chset, :payment_html))

  #   def get_print(chset, :price), do: get_field(chset, :price_print)
  #   def get_print(chset, field), do: get_field(chset, field)

  #   def raw_html(nil), do: nil
  #   def raw_html(str), do: raw(str)

  #   def get_error(chset, field) do
  #     case chset.errors[field] do
  #       {message, _extra} -> message
  #       nil -> nil
  #     end
  #   end

  #   def get_child(chset, :grouping), do: Bizzer.AdentryQuery.find(get_value(chset, :grouping_slug))
  #   def get_child(chset, :location), do: Bizzer.AdentryQuery.find(get_value(chset, :location_slug))

  #   def child_id(idx, pid), do: "#{idx}-#{pid}"
end
