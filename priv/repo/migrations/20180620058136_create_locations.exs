defmodule Bizzer.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :type, :integer, default: 0, null: false
      add :parent_id, :integer, default: 0

      add :name, :string, null: false
      add :slug, :citext, null: false

      timestamps()
    end

    create unique_index(:locations, [:slug])
    create index(:locations, [:parent_id])
  end
end
