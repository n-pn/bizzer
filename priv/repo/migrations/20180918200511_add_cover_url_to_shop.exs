defmodule Bizzer.Repo.Migrations.AddCoverUrlToShop do
  use Ecto.Migration

  def change do
    alter table(:shops) do
      add :cover_url, :string, default: "/img/cover.jpg"
    end
  end
end
