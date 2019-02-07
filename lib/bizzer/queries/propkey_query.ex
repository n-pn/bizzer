defmodule Bizzer.PropkeyQuery do
  use Bizzer, :repo
  alias Bizzer.{Propkey, Propval, PropvalQuery}

  def for_submit(nil, _), do: []

  def for_submit(grouping, propval_ids) do
    propkeys =
      from(
        r in Propkey,
        where: r.grouping_id == ^grouping.id,
        order_by: [asc: :id],
        preload: [:propvals],
        select: [:id, :type, :name, :slug]
      )
      |> Repo.all()

    propvals =
      PropvalQuery.glob(propval_ids)
      |> Stream.map(&{&1.propkey_id, &1})
      |> Enum.into(%{})

    IO.inspect(propkeys)

    for param <- propkeys, do: {param, propvals[param.id]}
  end

  def count(nil), do: Repo.count(Propkey)

  def count(grouping_id) do
    Propkey
    |> where(grouping_id: ^grouping_id)
    |> Repo.aggregate(:count, :id)
  end

  def fetch(nil), do: []
  def fetch(slugs), do: from(r in Propkey, where: r.slug in ^slugs) |> Repo.all()

  def glob(grouping_id, slugs) do
    from(r in Propkey, where: r.grouping_id == ^grouping_id, where: r.slug in ^slugs)
    |> Repo.all()
  end

  def list(opts \\ []) do
    Propkey
    |> order_by(asc: :id)
    |> where_grouping(opts[:grouping_id])
    |> preload_assocs(opts[:preload])
    |> Repo.all()
  end

  defp where_grouping(query, nil), do: query
  defp where_grouping(query, grouping_id), do: where(query, grouping_id: ^grouping_id)

  defp preload_assocs(query, true) do
    propvals = from(r in Propval, order_by: :id)
    preload(query, propvals: ^propvals)
  end

  defp preload_assocs(query, nil), do: query

  def get(nil), do: nil
  def get(id), do: Repo.get(Propkey, id)
  def get!(id), do: Repo.get!(Propkey, id)

  def find(nil, _), do: nil
  def find(_, nil), do: nil
  def find(grouping_id, slug), do: Repo.get_by(Propkey, grouping_id: grouping_id, slug: slug)
end
