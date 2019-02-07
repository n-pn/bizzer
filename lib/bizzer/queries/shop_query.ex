defmodule Bizzer.ShopQuery do
  use Bizzer, :repo
  alias Bizzer.Shop

  def count, do: Repo.count(Shop)

  def fetch(params \\ %{}) do
    Shop
    |> order_by(asc: :id)
    |> Repo.paginate(params[:page])
    |> Repo.all()
  end

  def get(nil), do: nil
  def get(id), do: Repo.get(Shop, id)
  def get!(id), do: Repo.get!(Shop, id)

  def find(nil), do: nil
  def find(slug), do: Repo.get_by(Shop, slug: slug)
  def find!(slug), do: Repo.get_by!(Shop, slug: slug)

  def find_by_user_id(nil), do: nil
  def find_by_user_id(user_id), do: Repo.get_by(Shop, user_id: user_id)
end
