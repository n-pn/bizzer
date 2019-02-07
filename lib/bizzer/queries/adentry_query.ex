defmodule Bizzer.AdentryQuery do
  use Bizzer, :repo

  alias Bizzer.{
    Adentry,
    PropvalQuery,
    LocationQuery,
    GroupingQuery
  }

  def get(nil), do: nil
  def get(id), do: Repo.get(Adentry, id) |> preload_single
  def get!(id), do: Repo.get!(Adentry, id) |> preload_single

  def find(nil), do: nil
  def find(slug), do: Repo.get_by(Adentry, slug: slug) |> preload_single
  def find!(slug), do: Repo.get_by!(Adentry, slug: slug) |> preload_single

  def get_random_pending(bag \\ 50) do
    from(
      r in Adentry,
      where: r.status == ^:pending,
      order_by: [desc: :updated_at],
      limit: ^bag,
      preload: [:user, :shop]
    )
    |> Repo.all()
    |> _sample
  end

  defp _sample([]), do: nil
  defp _sample(list) when is_list(list), do: Enum.random(list)
  defp _sample(_), do: nil

  def count, do: Repo.count(Adentry)
  def count(opts), do: Adentry |> _filtering(opts) |> Repo.count()

  def fetch(opts \\ []) do
    Adentry
    |> _filtering(opts)
    |> Repo.paginate(opts[:page], 12)
    |> preload([:user, :shop, :editor])
    |> Repo.all()
    |> preload_multi
  end

  defp _filtering(query, opts) do
    query
    |> Repo.where_equal(:status, _status(opts[:status]))
    |> Repo.where_equal(:user_id, opts[:user_id])
    |> Repo.where_equal(:shop_id, opts[:shop_id])
    |> Repo.where_contain(:grouping_ids, opts[:grouping_id])
    |> Repo.where_contain(:location_ids, opts[:location_id])
    |> Repo.where_contain(:propval_ids, opts[:propval_ids])
    |> Repo.where_equal(:user_type, opts[:user_type])
    |> Repo.where_equal(:user_need, opts[:user_need])
    |> _text_search(opts[:keyword])
    |> _filter_price_min(opts[:price_min])
    |> _filter_price_max(opts[:price_max])
    |> _sort_by(opts[:sort_by])
  end

  @status Bizzer.ReviewStatus.__enum_map__()
  def _status(nil), do: nil
  def _status(x) when is_integer(x), do: x
  def _status(x), do: Keyword.get(@status, x)

  defp _text_search(query, keyword) when is_binary(keyword) do
    from(r in query, where: fragment("unaccent(?) ilike unaccent(?)", r.subject, ^"%#{keyword}%"))
  end

  defp _text_search(query, _), do: query

  defp _filter_price_min(query, -1), do: query
  defp _filter_price_min(query, nil), do: query
  defp _filter_price_min(query, min), do: from(r in query, where: r.price >= ^min)

  defp _filter_price_max(query, -1), do: query
  defp _filter_price_max(query, nil), do: query
  defp _filter_price_max(query, max), do: from(r in query, where: r.price <= ^max)

  defp _sort_by(query, :price), do: query |> order_by(asc: :price)
  defp _sort_by(query, _), do: query |> order_by(desc: :id)

  def preload_single(nil), do: nil

  def preload_single(adentry) do
    locations = LocationQuery.glob(adentry.location_ids)
    groupings = GroupingQuery.glob(adentry.grouping_ids)

    properties =
      PropvalQuery.glob(adentry.propval_ids)
      |> Enum.map(&{&1.propkey, &1})

    adentry
    |> Repo.preload([:user, :shop, :editor])
    |> Map.put(:locations, locations)
    |> Map.put(:groupings, groupings)
    |> Map.put(:properties, properties)
    |> Map.put(:image_urls, _fix_image_urls(adentry.image_urls))
  end

  def preload_multi(nil), do: nil

  def preload_multi(adentries) do
    for adentry <- adentries do
      locations = LocationQuery.glob(adentry.location_ids)
      groupings = GroupingQuery.glob(adentry.grouping_ids)

      adentry
      |> Map.put(:locations, locations)
      |> Map.put(:groupings, groupings)
      |> Map.put(:image_urls, _fix_image_urls(adentry.image_urls))
    end
  end

  defp _fix_image_urls(nil), do: ["/img/blank.jpg"]
  defp _fix_image_urls([]), do: ["/img/blank.jpg"]
  defp _fix_image_urls(urls), do: urls
end
