defmodule Bizzer.Adentry do
  use Bizzer, :schema

  schema "adentries" do
    field :status, Bizzer.ReviewStatus, default: :pending
    belongs_to :editor, Bizzer.User

    belongs_to :user, Bizzer.User
    belongs_to :shop, Bizzer.Shop

    field :location_ids, {:array, :integer}, default: []
    field :location_name, :string
    field :location_slug, :string

    field :grouping_ids, {:array, :integer}, default: []
    field :grouping_name, :string
    field :grouping_slug, :string

    field :slug, :string

    field :subject, :string
    field :subject_slug, :string

    field :image_ids, {:array, :integer}, default: []
    field :image_urls, {:array, :string}

    field :details, :string
    field :details_html, :string

    field :price, :integer
    field :price_print, :string

    field :payment, :string
    field :payment_html, :string

    field :props, :map, virtual: true
    field :propval_ids, {:array, :integer}, default: []

    field :user_type, Bizzer.UserType
    field :user_need, Bizzer.UserNeed

    field :origin_src, Bizzer.OriginType, default: :bizzer
    field :origin_uid, :string

    timestamps()
  end

  @doc false

  @assoc_fields [:user_id, :shop_id, :location_slug, :grouping_slug]
  @required_fields [:subject, :details, :price]
  @extra_fields [:image_urls, :payment, :props, :user_type, :user_need]
  @manual_fields @assoc_fields ++ @required_fields ++ @extra_fields
  @import_fields @manual_fields ++
                   [:price_print, :origin_src, :origin_uid, :inserted_at, :updated_at, :status]

  def changeset(model, attrs, :manual) do
    model
    |> cast(attrs, @manual_fields)
    |> assign_slug
    |> put_change(:status, :pending)
    |> put_change(:origin_src, :bizzer)
    |> fill_origin_uid
    |> validate_content
  end

  def changeset(model, attrs, :update) do
    model
    |> cast(attrs, @manual_fields)
    |> put_change(:status, :pending)
    |> validate_content
  end

  def changeset(model, attrs, :review) do
    model
    |> cast(attrs, [:status, :editor_id, :image_urls])
  end

  def changeset(model, attrs, :change) do
    change(model, attrs)
  end

  def changeset(model, attrs, :import) do
    model
    |> cast(attrs, @import_fields)
    |> assign_slug
    # |> put_change(:status, :accepted)
    |> validate_origin_uid
    |> validate_content
  end

  defp validate_content(chset) do
    chset
    |> validate_locations
    |> validate_groupings
    |> validate_subject
    |> validate_images
    |> validate_details
    |> validate_price
    |> validate_payment
    |> validate_properties
    |> validate_user_type
  end

  defp validate_locations(chset) do
    locations =
      ConCache.get_or_store(:bizzer, :location_map, fn ->
        Bizzer.Repo.all(Bizzer.Location)
        |> Enum.map(&{&1.slug, &1})
        |> Enum.into(%{})
      end)

    case chset |> get_field(:location_slug) do
      nil ->
        chset |> add_error(:location_slug, "Bạn chưa chọn tên khu vực")

      location_slug ->
        case locations[location_slug] do
          nil ->
            chset |> add_error(:location_slug, "Tên khu vực không chính xác")

          location ->
            chset
            |> put_change(:location_name, location.name)
            |> put_change(:location_ids, extract_ids(location))
        end
    end
  end

  defp extract_ids(item) do
    if item.type == :parent, do: [item.id], else: [item.id, item.parent_id]
  end

  defp validate_groupings(chset) do
    groupings =
      ConCache.get_or_store(:bizzer, :grouping_map, fn ->
        Bizzer.Repo.all(Bizzer.Grouping)
        |> Enum.map(&{&1.slug, &1})
        |> Enum.into(%{})
      end)

    case chset |> get_field(:grouping_slug) do
      nil ->
        chset |> add_error(:grouping_slug, "Bạn chưa chọn tên chuyên mục")

      grouping_slug ->
        case groupings[grouping_slug] do
          nil ->
            chset |> add_error(:grouping_slug, "Tên chuyên mục không chính xác")

          grouping ->
            chset
            |> put_change(:grouping_name, grouping.name)
            |> put_change(:grouping_ids, extract_ids(grouping))
        end
    end
  end

  defp validate_subject(chset) do
    chset
    |> validate_required(:subject, message: "Bạn chưa điền tiêu đề")
    |> validate_length(
      :subject,
      max: 100,
      message: "Tiêu đề rao vặt không được dài quá 100 ký tự"
    )
    |> set_subject_slug()
  end

  defp set_subject_slug(%{changes: %{subject: subject}} = chset) do
    subject_slug = Bizzer.FormatUtil.slugify(subject, 40)
    chset |> put_change(:subject_slug, subject_slug)
  end

  defp set_subject_slug(chset), do: chset

  defp validate_images(%{changes: %{image_urls: urls}} = chset) when is_list(urls) do
    origin_src = chset |> get_field(:origin_src)

    if origin_src == :bizzer do
      image_ids = Bizzer.AdimageQuery.glob_by_urls(urls) |> Enum.map(& &1.id)
      chset |> put_change(:image_ids, image_ids)
    else
      image_ids =
        urls
        |> Enum.map(&Bizzer.AdimageAction.crelect(&1, origin_src))
        |> Enum.reject(&is_nil(&1))
        |> Enum.map(& &1.id)

      chset |> put_change(:image_ids, image_ids)
    end
  end

  defp validate_images(chset), do: chset

  defp validate_details(chset) do
    chset
    |> validate_required(:details, message: "Bạn chưa điền mô tả chi tiết")
    |> validate_length(
      :details,
      max: 10000,
      message: "Mô tả chi tiết không được dài quá 10000 ký tự"
    )
    |> render_details
  end

  defp render_details(%{changes: %{details: details}} = chset) do
    chset |> put_change(:details_html, render_html(details))
  end

  defp render_details(chset), do: chset

  defp validate_payment(chset) do
    chset
    |> validate_length(
      :payment,
      max: 2000,
      message: "Phương thức thanh toán không được dài quá 2000 ký tự"
    )
    |> render_payment
  end

  defp render_payment(%{changes: %{payment: payment}} = chset) do
    chset |> put_change(:payment_html, render_html(payment))
  end

  defp render_payment(chset), do: chset

  defp render_html(nil), do: nil

  defp render_html(text) do
    text
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn para ->
      para
      |> Plug.HTML.html_escape()
      |> String.split("\n", trim: true)
      |> Enum.join("<br/>")
    end)
    |> Enum.map(&"<p>#{&1}</p>")
    |> Enum.join()
  end

  defp validate_price(chset) do
    chset
    |> validate_required(:price, message: "Bạn chưa nhập giá")
    |> render_price
  end

  defp render_price(%{changes: %{price_print: price}} = chset) when is_binary(price), do: chset

  defp render_price(%{changes: %{price: price}} = chset) do
    price_print = Bizzer.FormatUtil.money_to_vnd(price)
    chset |> put_change(:price_print, price_print)
  end

  defp render_price(chset), do: chset

  defp validate_properties(%{changes: %{grouping_ids: grouping_ids, properties: attrs}} = chset)
       when is_map(attrs) do
    alias Bizzer.{PropkeyQuery, PropvalQuery}

    grouping_id = grouping_ids |> List.first()

    propval_ids =
      for {param, value} <- attrs do
        adparam = PropkeyQuery.find(grouping_id, param)
        advalue = if adparam, do: PropvalQuery.find(adparam.id, value), else: nil
        if advalue, do: advalue.id, else: nil
      end
      |> Enum.reject(&is_nil(&1))

    chset |> put_change(:propval_ids, propval_ids)
  end

  defp validate_properties(chset), do: chset

  defp validate_user_type(chset) do
    case chset |> get_field(:user_type) do
      :"ban-chuyen" ->
        user_id = chset |> get_field(:user_id)
        user = Bizzer.UserQuery.get(user_id)

        case Bizzer.ShopQuery.find_by_user_id(user.id) do
          nil -> chset
          shop -> chset |> put_change(:shop_id, shop.id)
        end

      _ ->
        chset
    end
  end

  defp assign_slug(chset) do
    chset
    |> put_change(:slug, Bizzer.RandUtil.string(8))
    |> unique_constraint(:slug)
  end

  def validate_origin_uid(chset) do
    chset
    |> unique_constraint(:origin_uid, name: "adentries_origin_index")
  end

  defp fill_origin_uid(%{changes: %{origin_uid: uid}} = chset) when is_binary(uid), do: chset

  defp fill_origin_uid(%{changes: %{slug: slug}} = chset) do
    chset |> put_change(:origin_uid, slug)
  end

  defp fill_origin_uid(chset), do: chset
end
