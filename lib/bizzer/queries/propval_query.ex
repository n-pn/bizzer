defmodule Bizzer.PropvalQuery do
  use Bizzer, :repo
  alias Bizzer.Propval

  def count(nil), do: Repo.aggregate(Propval, :count, :id)

  def count(propkey_id) do
    Propval
    |> where(propkey_id: ^propkey_id)
    |> Repo.aggregate(:count, :id)
  end

  def glob(nil), do: []
  def glob(ids), do: from(r in Propval, where: r.id in ^ids, preload: [:propkey]) |> Repo.all()

  def glob(ids, propkey_ids) do
    from(
      r in Propval,
      where: r.id in ^ids,
      where: r.propkey_id in ^propkey_ids,
      preload: [:propkey]
    )
    |> Repo.all()
  end

  def fetch(nil), do: []
  def fetch(slugs), do: from(r in Propval, where: r.slug in ^slugs) |> Repo.all()

  def list(opts \\ []) do
    Propval
    |> order_by(asc: :id)
    |> where_propkey(opts[:propkey_id])
    |> Repo.all()
  end

  defp where_propkey(query, nil), do: query
  defp where_propkey(query, propkey_id), do: query |> where(propkey_id: ^propkey_id)

  def get(nil), do: nil
  def get(id), do: Repo.get(Propval, id)
  def get!(id), do: Repo.get!(Propval, id)

  def find(_, nil), do: nil
  def find(nil, _), do: nil
  def find(propkey_id, slug), do: Repo.get_by(Propval, propkey_id: propkey_id, slug: slug)
end
