defmodule Bizzer.Shop do
  use Bizzer, :schema

  schema "shops" do
    field :status, Bizzer.ShopStatus, default: :pending
    belongs_to :editor, Bizzer.User

    belongs_to :user, Bizzer.User

    field :name, :string
    field :slug, :string
    field :phone, :string
    field :address, :string
    field :details, :string
    field :cover_url, :string, default: "/img/cover.jpg"
    field :avatar_url, :string, default: "/img/avatar.png"

    field :origin_src, Bizzer.OriginType, default: :bizzer
    field :origin_uid, :string

    timestamps()
  end

  @doc false

  def changeset(model, attrs, :change) do
    model
    |> change(attrs)
  end

  @fields [:name, :details, :phone, :address, :avatar_url, :cover_url]
  def changeset(model, attrs, :update) do
    model
    |> cast(attrs, @fields)
    |> validate_required(:name, message: "Bạn chưa điền tên cửa hàng")
  end

  @fields @fields ++ [:user_id, :slug]
  def changeset(model, attrs, :manual) do
    model
    |> cast(attrs, @fields)
    |> validate_required(:name, message: "Bạn chưa điền tên cửa hàng")
    |> validate_required(:slug, message: "Bạn chưa điền đường dẫn")
    |> validate_required(:address, message: "Bạn chưa điền địa chỉ")
    |> validate_required(:phone, message: "Bạn chưa điền điện thoại liên hệ")
    |> validate_required(:avatar_url, message: "Bạn chưa điền ảnh đại diện")
    |> validate_required(:cover_url, message: "Bạn chưa điền ảnh chuyên trang")
    |> unique_constraint(:slug, message: "Đường dẫn cửa hàng đã bị sử dụng")
    |> fill_origin_uid()
    |> validate_origin_uid
  end

  @import_fields @fields ++ [:origin_uid, :origin_src, :inserted_at]
  def changeset(model, attrs, :import) do
    model
    |> cast(attrs, @import_fields)
    |> put_change(:status, :accepted)
    |> validate_required(:name, message: "Bạn chưa đền tên cửa hàng")
    |> validate_required(:slug, message: "Bạn chưa đền đường dẫn")
    |> unique_constraint(:slug, message: "Đường dẫn cửa hàng đã bị sử dụng")
    |> validate_origin_uid
  end

  defp fill_origin_uid(changeset) do
    uid = changeset |> get_field(:slug)

    changeset
    |> put_change(:origin_src, :bizzer)
    |> put_change(:origin_uid, uid)
  end

  defp validate_origin_uid(changeset) do
    changeset
    |> unique_constraint(:origin_uid, name: "shops_origin_index")
  end
end
