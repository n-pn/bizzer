defmodule Bizzer.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    belongs_to :user, Bizzer.User

    field :type, Bizzer.NotifyType
    field :data, :map
    field :read, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(struct, attrs, :create) do
    struct
    |> cast(attrs, [:user_id, :type, :data])
    |> validate_required([:user_id, :type, :data])
  end

  def changeset(struct, attrs, :update) do
    struct
    |> cast(attrs, [:read])
    |> validate_required([:read])
  end
end
