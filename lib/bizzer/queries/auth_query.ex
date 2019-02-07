defmodule Bizzer.AuthQuery do
  use Bizzer, :repo
  alias Bizzer.Auth

  def get(nil), do: nil
  def get(id), do: Repo.get(Auth, id)

  def find(nil), do: nil
  def find(token), do: Repo.get_by(Auth, token: token, expired: false)
end
