defmodule Bizzer.GroupingAction do
  use Bizzer, :repo
  alias Bizzer.Grouping

  def create(attrs \\ %{}) do
    %Grouping{}
    |> Grouping.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Grouping{} = grouping, attrs) do
    grouping
    |> Grouping.changeset(attrs)
    |> Repo.update()
  end

  def change(%Grouping{} = grouping) do
    Grouping.changeset(grouping, %{})
  end
end
