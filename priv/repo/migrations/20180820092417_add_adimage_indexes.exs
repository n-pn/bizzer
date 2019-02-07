defmodule Bizzer.Repo.Migrations.AddAdimageIndexes do
  use Ecto.Migration

  def change do
    create index(:adimages, [:status, :updated_at], name: "adimages_status_index")
    create index(:adimages, [:updated_at])
  end
end
