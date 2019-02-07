defmodule Bizzer.UserQuery do
  use Bizzer, :repo
  alias Bizzer.User

  def count(nil), do: Repo.count(User)

  def fetch(opts \\ []) do
    User
    |> order_by(asc: :id)
    |> Repo.where_equal(:role, opts[:role])
    |> Repo.paginate(opts[:page])
    |> Repo.all()
  end

  def get(nil), do: nil
  def get(id), do: Repo.get(User, id)
  def get!(id), do: Repo.get!(User, id)

  def get_by(nil), do: nil
  def get_by(opts), do: Repo.get_by(User, opts)
  def get_by!(opts), do: Repo.get_by!(User, opts)

  def find(slug), do: get_by(slug: slug)

  def find_origin(uid, src \\ 0), do: Repo.get_by(User, origin_uid: uid, origin_src: src)
end
