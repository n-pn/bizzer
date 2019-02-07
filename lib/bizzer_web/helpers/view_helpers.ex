defmodule BizzerWeb.ViewHelpers do
  use Phoenix.HTML

  def gen_image_url(url) do
    if Mix.env() == :prod do
      String.replace(url, "/uploads/", "https://upload.bizzer.store/")
    else
      url
    end
  end

  def form_error(form, field, id \\ "") do
    errors = Keyword.get_values(form.errors, field)

    if length(errors) > 0 do
      {error, _} = List.first(errors)
      content_tag :span, error, class: "form-message _error", id: "#{id}-message"
    else
      nil
    end
  end

  def current_path(conn) do
    Phoenix.Controller.current_path(conn)
  end

  def best_image(adimage) do
    adimage.public_url || adimage.static_url || adimage.origin_url
  end

  def user_types, do: [{"Cá nhân", :"ca-nhan"}, {"Bán chuyên", :"ban-chuyen"}]
  def user_needs, do: [{"Cần bán", :"can-ban"}, {"Cần mua", :"can-mua"}]

  def is_empty(nil), do: " _empty"
  def is_empty(_), do: nil

  def is_active(a, b) when a != b, do: nil
  def is_active(_, _), do: " _active"

  def on_child(:nested, %{type: :child}), do: " _child"
  def on_child(_, _), do: nil

  def extract_error(form, field) do
    form.errors[field]
    |> elem(0)
  end

  import Ecto.Changeset

  def get_value(chset, :images) do
    chset
    |> get_value(:image_ids)
    |> Bizzer.AdimageQuery.glob()
  end

  def get_value(chset, field), do: get_field(chset, field)

  def get_print(chset, :user_type) do
    case get_field(chset, :user_type) do
      nil -> nil
      :"ca-nhan" -> "Cá nhân"
      :"ban-chuyen" -> "Bán chuyên"
    end
  end

  def get_print(chset, :user_need) do
    case get_field(chset, :user_need) do
      nil -> nil
      :"can-ban" -> "Cần bán/Cho thuê"
      :"can-mua" -> "Cần mua/Muốn thuê"
    end
  end

  def get_print(chset, :subject), do: get_field(chset, :subject)
  def get_print(chset, :details), do: raw_html(get_field(chset, :details_html))
  def get_print(chset, :payment), do: raw_html(get_field(chset, :payment_html))

  def get_print(chset, :price), do: get_field(chset, :price_print)
  def get_print(chset, field), do: get_field(chset, field)

  def raw_html(nil), do: nil
  def raw_html(str), do: raw(str)

  def get_error(chset, field) do
    case chset.errors[field] do
      {message, _extra} -> message
      nil -> nil
    end
  end

  def get_child(chset, :grouping), do: Bizzer.AdentryQuery.find(get_value(chset, :grouping_slug))
  def get_child(chset, :location), do: Bizzer.AdentryQuery.find(get_value(chset, :location_slug))

  def child_id(idx, pid), do: "#{idx}-#{pid}"
end
