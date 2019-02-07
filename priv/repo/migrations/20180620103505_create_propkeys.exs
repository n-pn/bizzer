defmodule Bizzer.Repo.Migrations.CreatePropkeys do
  use Ecto.Migration

  def change do
    create table(:propkeys) do
      add :grouping_id, references(:groupings, on_delete: :nothing)

      add :type, :integer, default: 0, null: false
      add :parent_id, references(:propkeys, on_delete: :nothing)

      add :name, :string, null: false
      add :slug, :string, null: false

      # add :query_type, :integer, default: 0

      timestamps()
    end

    create unique_index(:propkeys, [:grouping_id, :slug], name: "propkeys_unique_index")
    create index(:propkeys, [:parent_id])
    create index(:propkeys, [:slug])
  end
end
