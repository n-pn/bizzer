defmodule Bizzer.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :user_id, references(:users, on_delete: :nothing)

      add :type, :integer
      add :data, :map
      add :read, :boolean, default: false, null: false

      timestamps()
    end

    create index(:notifications, [:user_id])
  end
end
