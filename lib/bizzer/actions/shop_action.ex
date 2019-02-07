defmodule Bizzer.ShopAction do
  use Bizzer, :repo
  alias Bizzer.Shop

  def insert(attrs, type \\ :import) when type in [:import, :manual] do
    %Shop{}
    |> Shop.changeset(attrs, type)
    |> Repo.insert()
  end

  def update(%Shop{} = shop, attrs) do
    shop
    |> Shop.changeset(attrs, :update)
    |> Repo.update()
  end

  def delete(%Shop{} = shop) do
    Repo.delete(shop)
  end

  def change(attrs \\ %{}, shop \\ %Shop{}) do
    Shop.changeset(shop, attrs, :change)
  end
end
