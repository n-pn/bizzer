defmodule Bizzer.Repo.Migrations.AddPostgresExtensions do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;")
    execute("CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;")
    execute("CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;")
  end
end
