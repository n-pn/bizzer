defmodule Bizzer.User do
  use Bizzer, :schema

  schema "users" do
    field :slug, :string
    field :role, Bizzer.UserRole, default: :member

    field :phone, :string
    field :crypted_password, :string

    field :name, :string
    field :email, :string
    field :address, :string
    field :avatar_url, :string, default: "/img/avatar.png"

    field :origin_src, Bizzer.OriginType, default: :bizzer
    field :origin_uid, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :old_password, :string, virtual: true

    timestamps()
  end

  @doc false

  @change_fields [:phone, :name, :email, :address, :password]

  def changeset(model, attrs, :change) do
    model |> cast(attrs, @change_fields)
  end

  @signup_fields @change_fields ++ [:password_confirmation]

  def changeset(model, attrs, :signup) do
    model
    |> cast(attrs, @signup_fields)
    |> validate_phone
    |> validate_name
    |> validate_email
    |> validate_address
    |> validate_password
    |> set_random_slug
    |> copy_slug_to_origin_uid
    |> validate_origin_uid
  end

  @manual_fields @change_fields ++ [:role]

  def changeset(model, attrs, :manual) do
    model
    |> cast(attrs, @manual_fields)
    |> validate_phone
    |> validate_email
    |> encrypt_password
    |> set_random_slug
    |> copy_slug_to_origin_uid
    |> validate_origin_uid
  end

  @import_fields @change_fields ++ [:origin_uid, :origin_src, :crypted_password]

  def changeset(model, attrs, :import) do
    model
    |> cast(attrs, @import_fields)
    |> validate_phone
    |> validate_email
    |> set_random_slug
    |> validate_origin_uid
  end

  def changeset(model, attrs, :profile) do
    model
    |> cast(attrs, [:name, :address])
    |> validate_name
    |> validate_address
  end

  def changeset(model, attrs, :password) do
    model
    |> cast(attrs, [:old_password, :password, :password_confirmation])
    |> validate_old_password
    |> validate_password
  end

  defp validate_phone(chset) do
    chset
    |> validate_required(:phone, messsage: "Bạn chưa điền số điện thoại")
    |> unique_constraint(:phone, message: "Số điện thoại đã bị sử dụng")
  end

  defp validate_email(chset) do
    chset
    |> validate_required(:email, messsage: "Bạn chưa điền địa chỉ email")
    |> validate_format(:email, ~r/@/, messsage: "Địa chỉ email không đúng định dạng")
    |> validate_length(:email, max: 100, message: "Địa chỉ email không được dài quá 100 ký tự")

    # |> unique_constraint(:email, message: "Địa chỉ email đã bị sử dụng")
  end

  defp validate_name(chset) do
    chset
    |> validate_required(:name, messsage: "Bạn chưa điền tên hiển thị")
    |> validate_length(:name, max: 30, message: "Tên hiển thị không được dài quá 30 ký tự")
  end

  defp validate_address(chset) do
    chset
    # |> validate_required(:address, messsage: "Bạn chưa điền địa chỉ")
    |> validate_length(:address, max: 1000, message: "Địa chỉ không được dài quá 1000 ký tự")
  end

  defp validate_old_password(chset) do
    case chset |> get_change(:old_password) do
      nil ->
        chset |> add_error(:old_password, "Bạn chưa điền mật khẩu cũ")

      old_password ->
        crypted_password = chset |> get_field(:crypted_password)

        if Pbkdf2.verify_pass(old_password, crypted_password) do
          chset
        else
          add_error(chset, :old_password, "Mật khẩu cũ không trùng khớp")
        end
    end
  end

  defp validate_password(chset) do
    chset
    |> validate_required(:password, message: "Bạn chưa điền mật khẩu")
    |> validate_length(:password, min: 8, message: "Mật khẩu phải có ít nhất 8 ký tự")
    |> validate_confirmation(:password, message: "Mật khẩu nhập lại không trùng khớp")
    |> encrypt_password
  end

  defp encrypt_password(%{valid?: true, changes: %{password: password}} = chset) do
    crypted_password = Pbkdf2.hash_pwd_salt(password)
    chset |> put_change(:crypted_password, crypted_password)
  end

  defp encrypt_password(chset), do: chset

  defp set_random_slug(%{changes: %{slug: slug}} = chset) when is_binary(slug), do: chset

  defp set_random_slug(chset) do
    chset
    |> put_change(:slug, Bizzer.RandUtil.string(8))
    |> unique_constraint(:slug, message: "UID trùng lặp, mời nhập lại")
  end

  defp copy_slug_to_origin_uid(chset) do
    slug = chset |> get_field(:slug)

    chset
    |> put_change(:origin_src, :bizzer)
    |> put_change(:origin_uid, slug)
  end

  defp validate_origin_uid(chset) do
    chset |> unique_constraint(:origin_uid, name: "users_origin_index")
  end
end
