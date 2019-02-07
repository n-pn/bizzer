defmodule Bizzer.Propkey do
  use Bizzer, :schema

  schema "propkeys" do
    belongs_to :grouping, Bizzer.Grouping
    has_many :propvals, Bizzer.Propval, foreign_key: :propkey_id

    field :type, Bizzer.PropType, default: :parent
    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    field :name, :string
    field :slug, :string

    # field :query_type, Bizzer.QueryType, default: :checkbox

    timestamps()
  end

  @doc false
  def changeset(proptype, attrs) do
    proptype
    |> cast(attrs, [:grouping_id, :parent_id, :slug, :name])
    |> validate_required(:name, message: "Bạn chưa nhập tên phân loại")
    |> slugify()
    |> unique_constraint(
      :slug,
      name: "propkeys_unique_index",
      message: "Tên phân loại đã bị sử dụng"
    )
  end

  defp slugify(%{changes: %{name: name, slug: nil}} = chset) do
    chset
    |> put_change(:slug, Bizzer.FormatUtil.slugify(name))
  end

  defp slugify(chset), do: chset
end
