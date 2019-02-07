defmodule Bizzer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :role, :integer, default: 1, null: false
      add :slug, :citext, null: false

      add :phone, :string, null: false
      add :crypted_password, :string, null: false

      add :name, :string
      add :email, :citext
      add :address, :text
      add :avatar_url, :text

      add :origin_src, :integer, default: 0
      add :origin_uid, :string

      timestamps()
    end

    create unique_index(:users, [:slug])
    create unique_index(:users, [:phone])
    create unique_index(:users, [:origin_src, :origin_uid], name: "users_origin_index")
  end
end
