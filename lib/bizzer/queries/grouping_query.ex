defmodule Bizzer.GroupingQuery do
  use Bizzer, :repo
  alias Bizzer.Grouping

  @all_type %{
    id: 0,
    type: :parent,
    parent_id: nil,
    slug: "tat-ca-chuyen-muc",
    name: "Tất cả chuyên mục"
  }

  def get(nil), do: nil
  def get(0), do: @all_type
  def get(id), do: Repo.get(Grouping, id)
  def get!(id), do: Repo.get!(Grouping, id)

  def find(nil), do: nil
  def find("tat-ca-chuyen-muc"), do: @all_type
  def find(slug), do: Repo.get_by(Grouping, slug: slug)
  def find!(slug), do: Repo.get_by!(Grouping, slug: slug)

  def glob(nil), do: []
  def glob([]), do: []
  def glob(ids), do: from(r in Grouping, where: r.id in ^ids) |> Repo.all()

  def fetch do
    ConCache.get_or_store(:bizzer, :groupings, fn ->
      query(type: :parent, preload: true)
    end)
  end

  def query(opts \\ []) do
    Grouping
    |> order_by(asc: :id)
    |> filter_type(opts[:type], opts[:parent_id])
    |> preload_assoc(opts[:preload], opts[:type])
    |> Repo.all()
  end

  defp filter_type(query, :parent, _), do: query |> where([r], r.type == 0)
  defp filter_type(query, :child, nil), do: query |> where([r], r.type == 1)

  defp filter_type(query, :child, parent_id) when is_integer(parent_id) do
    from(
      r in query,
      where: r.type == 1,
      where: r.parent_id == ^parent_id
    )
  end

  defp filter_type(query, _, _), do: query

  defp preload_assoc(query, true, :parent), do: query |> preload(:children)
  defp preload_assoc(query, true, :child), do: query |> preload(:parent)
  defp preload_assoc(query, _, _), do: query
end
