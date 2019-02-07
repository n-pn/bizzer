defmodule Bizzer.Grouping do
  use Bizzer, :schema

  schema "groupings" do
    field :type, Bizzer.PropType, default: :parent
    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(grouping, attrs) do
    grouping
    |> cast(attrs, [:name, :slug, :type, :parent_id])
    |> validate_required(:name, message: "Bạn chưa điền tên chuyên mục")
    |> slugify()
    |> unique_constraint(:slug, message: "Tên chuyên mục đã bị sử dụng")
  end

  defp slugify(%{changes: %{name: name, slug: nil}} = chset) do
    chset
    |> put_change(:slug, Bizzer.FormatUtil.slugify(name))
  end

  defp slugify(chset), do: chset
end
