defmodule Bizzer.AdimageQuery do
  use Bizzer, :repo
  alias Bizzer.Adimage

  def count, do: Repo.count(Adimage)
  def count(opts), do: Adimage |> _queries(opts) |> Repo.count()

  def fetch(opts \\ []) do
    Adimage
    |> _queries(opts)
    |> Repo.paginate(opts[:page])
    |> order_by(desc: :updated_at)
    |> preload([:worker])
    |> Repo.all()
  end

  def _queries(query, opts) do
    query
    |> filter_status(opts[:status])
    |> filter_period(opts[:period])
    |> filter_worker(opts[:worker])
  end

  defp filter_period(query, nil), do: query
  defp filter_period(query, time), do: where(query, [r], r.updated_at >= ^time)

  defp filter_worker(query, nil), do: query
  defp filter_worker(query, id), do: where(query, [r], r.worker_id == ^id)

  defp filter_status(query, :unedit), do: from(r in query, where: r.status == 0)
  defp filter_status(query, :edited), do: from(r in query, where: r.status == 1)
  defp filter_status(query, _), do: query

  def get(id) do
    Adimage
    |> where([r], r.id == ^id)
    |> preload(:worker)
    |> Repo.one()
  end

  def glob(ids) when is_list(ids) do
    from(r in Adimage, where: r.id in ^ids)
    |> Repo.all()
  end

  def glob(_), do: []

  def glob_by_urls(urls) when is_list(urls) do
    from(
      r in Adimage,
      where: r.public_url in ^urls,
      or_where: r.static_url in ^urls,
      or_where: r.origin_url in ^urls
    )
    |> Repo.all()
  end

  def glob_by_urls(_), do: []

  def get_random_unedit do
    from(r in Adimage, where: r.status == 0, order_by: [desc: :id], limit: 40)
    |> Repo.all()
    |> Enum.random()
  end
end
