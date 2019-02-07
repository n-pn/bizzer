defmodule Bizzer.Repo.Migrations.CreateGroupings do
  use Ecto.Migration

  def change do
    create table(:groupings) do
      add :type, :integer, default: 0, null: false
      add :parent_id, :integer, default: 0

      add :name, :string, null: false
      add :slug, :citext, null: false

      timestamps()
    end

    create unique_index(:groupings, [:slug])
    create index(:groupings, [:parent_id])
  end
end
