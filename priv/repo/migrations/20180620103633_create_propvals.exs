defmodule Bizzer.Repo.Migrations.CreatePropvals do
  use Ecto.Migration

  def change do
    create table(:propvals) do
      add :propkey_id, references(:propkeys, on_delete: :nothing)

      add :type, :integer, default: 0, null: false
      add :parent_id, references(:propvals, on_delete: :nothing)

      add :name, :string
      add :slug, :citext

      timestamps()
    end

    create unique_index(:propvals, [:propkey_id, :slug], name: "propvals_unique_index")
    create index(:propvals, [:parent_id])
    create index(:propvals, [:slug])
  end
end
