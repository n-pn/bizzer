defmodule Bizzer.Location do
  use Bizzer, :schema

  schema "locations" do
    field :type, Bizzer.PropType, default: :parent
    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:name, :slug, :type, :parent_id])
    |> validate_required(:name, message: "Bạn chưa nhập tên khu vực")
    |> slugify()
    |> unique_constraint(:slug, message: "Tên khu vực đã bị sử dụng")
  end

  defp slugify(%{changes: %{name: name, slug: nil}} = chset) do
    chset
    |> put_change(:slug, Bizzer.FormatUtil.slugify(name))
  end

  defp slugify(chset), do: chset
end
