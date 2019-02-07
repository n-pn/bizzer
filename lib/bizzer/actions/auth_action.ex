defmodule Bizzer.AuthAction do
  use Bizzer, :repo
  alias Bizzer.Auth

  def change(attrs), do: Auth.changeset(%Auth{}, attrs, :change)

  @types [:login, :signup]

  def insert(attrs, type \\ :login) when type in @types do
    Auth.changeset(%Auth{}, attrs, type)
    |> Repo.insert()
  end

  def delete(%Auth{} = auth) do
    Auth.changeset(auth, :logout)
    |> Repo.update()
  end
end
