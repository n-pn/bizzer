defmodule Bizzer.Repo.Migrations.CreateShops do
  use Ecto.Migration

  def change do
    create table(:shops) do
      add :status, :integer, default: 0, null: false
      add :editor_id, references(:users, on_delete: :nothing)

      add :user_id, references(:users, on_delete: :nothing)

      add :name, :string, null: false
      add :slug, :citext, null: false
      add :phone, :string
      add :address, :text
      add :details, :text
      add :avatar_url, :string

      add :origin_src, :integer, default: 0, null: false
      add :origin_uid, :citext

      timestamps()
    end

    create unique_index(:shops, [:slug])
    create unique_index(:shops, [:origin_src, :origin_uid], name: "shops_origin_index")
    create index(:shops, [:editor_id])
    create index(:shops, [:user_id])
  end
end
