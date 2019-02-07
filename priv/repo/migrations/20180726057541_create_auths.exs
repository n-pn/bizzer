defmodule Bizzer.Repo.Migrations.CreateAuths do
  use Ecto.Migration

  def change do
    create table(:auths) do
      add :user_id, references(:users, on_delete: :nothing)

      add :token, :string, null: false
      add :expired, :boolean, default: false

      timestamps()
    end

    create unique_index(:auths, [:token])
    create index(:auths, [:user_id])
  end
end
