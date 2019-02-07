defmodule Bizzer.Propval do
  use Bizzer, :schema

  schema "propvals" do
    belongs_to :propkey, Bizzer.Propkey

    field :type, Bizzer.PropType, default: :parent
    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(propinfo, attrs) do
    propinfo
    |> cast(attrs, [:propkey_id, :parent_id, :slug, :name])
    |> validate_required(:name, message: "Bạn chưa nhập tên lựa chọn")
    |> slugify()
    |> unique_constraint(
      :slug,
      name: "propvals_unique_index",
      message: "Tên lựa chọn đã bị sử dụng"
    )
  end

  defp slugify(%{changes: %{name: name, slug: nil}} = chset) do
    chset
    |> put_change(:slug, Bizzer.FormatUtil.slugify(name))
  end

  defp slugify(chset), do: chset
end
