defmodule Bizzer.PropkeyAction do
  use Bizzer, :repo
  alias Bizzer.Propkey

  def create(attrs \\ %{}) do
    %Propkey{}
    |> Propkey.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Propkey{} = struct, attrs) do
    struct
    |> Propkey.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Propkey{} = struct) do
    Repo.delete(struct)
  end

  def change(%Propkey{} = struct) do
    Propkey.changeset(struct, %{})
  end
end
