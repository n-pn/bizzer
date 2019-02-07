defmodule Bizzer.PropvalAction do
  use Bizzer, :repo
  alias Bizzer.Propval

  def create(attrs \\ %{}) do
    %Propval{}
    |> Propval.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Propval{} = propval, attrs) do
    propval
    |> Propval.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Propval{} = propval) do
    Repo.delete(propval)
  end

  def change(%Propval{} = propval) do
    Propval.changeset(propval, %{})
  end
end
