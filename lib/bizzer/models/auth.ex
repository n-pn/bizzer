defmodule Bizzer.Auth do
  use Bizzer, :schema

  schema "auths" do
    belongs_to :user, Bizzer.User

    field :token, :string
    field :expired, :boolean, default: false

    field :phone, :string, virtual: true
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(model, attrs, :change) do
    model
    |> cast(attrs, [:phone])
  end

  def changeset(model, attrs, :login) do
    model
    |> cast(attrs, [:phone, :password])
    |> validate_required(:phone, message: "Bạn chưa điền số điện thoại")
    |> validate_required(:password, message: "Bạn chưa điền mật khẩu")
    |> authenticate
  end

  def changeset(model, attrs, :signup) do
    model
    |> cast(attrs, [:user_id])
    |> generate_token
  end

  def changeset(model, :logout) do
    model
    |> change()
    |> put_change(:expired, true)
  end

  defp authenticate(%{valid?: true, changes: %{phone: phone, password: password}} = chset) do
    case Bizzer.UserQuery.get_by(phone: phone) do
      nil ->
        Pbkdf2.no_user_verify()

        add_error(chset, :phone, "Số điện thoại không tồn tại")

      user ->
        if Pbkdf2.verify_pass(password, user.crypted_password) do
          chset
          |> put_change(:user_id, user.id)
          |> generate_token
        else
          add_error(chset, :password, "Mật khẩu không trùng khớp")
        end
    end
  end

  defp authenticate(chset), do: chset

  defp generate_token(chset) do
    chset
    |> put_change(:token, Bizzer.RandUtil.string())
    |> unique_constraint(:token)
  end
end
