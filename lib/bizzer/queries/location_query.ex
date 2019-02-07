defmodule Bizzer.LocationQuery do
  use Bizzer, :repo
  alias Bizzer.Location

  def get(nil), do: nil
  def get(id), do: Repo.get(Location, id)
  def get!(id), do: Repo.get!(Location, id)

  def find(nil), do: nil

  def find("toan-quoc"),
    do: %{id: 0, type: :parent, name: "Toàn quốc", slug: "toan-quoc", parent_id: nil}

  def find(slug), do: Repo.get_by(Location, slug: slug)
  def find!(slug), do: Repo.get_by!(Location, slug: slug)

  def get_by(nil), do: nil
  def get_by(opts), do: Repo.get_by(Location, opts)
  def get_by!(opts), do: Repo.get_by!(Location, opts)

  def glob(nil), do: []
  def glob([]), do: []
  def glob(ids), do: from(r in Location, where: r.id in ^ids) |> Repo.all()

  def fetch do
    ConCache.get_or_store(:bizzer, :locations, fn ->
      query(type: :parent, preload: true)
    end)
  end

  def query(opts \\ []) do
    Location
    |> order_by(asc: :id)
    |> filter_type(opts[:type], opts[:parent_id])
    |> preload_assoc(opts[:preload], opts[:type])
    |> Repo.all()
  end

  defp filter_type(query, :parent, _), do: query |> where([r], r.type == 0)

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
