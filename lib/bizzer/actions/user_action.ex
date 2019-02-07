defmodule Bizzer.UserAction do
  use Bizzer, :repo
  alias Bizzer.User

  def change(params, struct \\ %User{}), do: User.changeset(struct, params, :change)

  @types [:manual, :signup, :import]
  def insert(attrs, type \\ :signup) when type in @types do
    %User{}
    |> User.changeset(attrs, type)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs, type) do
    user
    |> User.changeset(attrs, type)
    |> Repo.update()
  end

  def delete(%User{} = user) do
    Repo.delete(user)
  end
end
