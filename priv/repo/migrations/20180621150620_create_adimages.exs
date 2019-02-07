defmodule Bizzer.Repo.Migrations.CreateAdimages do
  use Ecto.Migration

  def change do
    create table(:adimages) do
      add :status, :integer, default: 0, null: false
      add :worker_id, references(:users, on_delete: :nothing)

      add :static_url, :string
      add :public_url, :string

      add :x_offset, :integer
      add :y_offset, :integer

      add :width, :integer
      add :height, :integer

      add :origin_src, :integer, default: 0
      add :origin_url, :string

      timestamps()
    end

    create unique_index(:adimages, [:origin_url])
    create unique_index(:adimages, [:public_url])

    create index(:adimages, [:worker_id, :status], name: "adimages_worker_id_index")
  end
end
