defmodule Bizzer.Repo do
  use Ecto.Repo, otp_app: :bizzer

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def count(query, field \\ :id), do: aggregate(query, :count, field)

  import Ecto.Query

  @doc "Pagination with fallback"
  def paginate(query, page \\ 1, limit \\ 24)
  def paginate(query, nil, limit), do: paginate(query, 1, limit)
  def paginate(query, page, limit) when page < 1, do: paginate(query, 1, limit)
  def paginate(query, page, limit) when limit < 1, do: paginate(query, page, 24)

  def paginate(query, page, limit),
    do: from(r in query, limit: ^limit, offset: ^((page - 1) * limit))

  @doc "Filter query by field equal to value, ignored if no value given"

  def where_equal(query, _, nil), do: query
  def where_equal(query, col, value), do: from(r in query, where: field(r, ^col) == ^value)

  @doc "Where array has values"

  def where_contain(query, _, nil), do: query
  def where_contain(query, _, 0), do: query

  def where_contain(query, col, value) when is_list(value),
    do: from(r in query, where: fragment("? @> ?", field(r, ^col), ^value))

  def where_contain(query, col, value),
    do: from(r in query, where: fragment("? @> ?", field(r, ^col), ^[value]))
end
