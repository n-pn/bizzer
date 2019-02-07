defmodule Bizzer.LocationAction do
  use Bizzer, :repo
  alias Bizzer.Location

  def create(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  def change(%Location{} = location) do
    Location.changeset(location, %{})
  end
end
