defmodule Bizzer.Repo.Migrations.CreateAdentries do
  use Ecto.Migration

  def change do
    create table(:adentries) do
      add :status, :integer, default: 0, null: false
      add :editor_id, references(:users, on_delete: :nothing)

      add :user_id, references(:users, on_delete: :nothing)
      add :shop_id, references(:shops, on_delete: :nothing)

      add :location_ids, {:array, :integer}
      add :location_name, :string
      add :location_slug, :string

      add :grouping_ids, {:array, :integer}
      add :grouping_name, :string
      add :grouping_slug, :string

      add :slug, :citext

      add :subject, :text
      add :subject_slug, :string

      add :image_ids, {:array, :id}
      add :image_urls, {:array, :string}

      add :details, :text
      add :details_html, :text

      add :price, :bigint, default: 0
      add :price_print, :string, default: "0đ"

      add :payment, :text
      add :payment_html, :text

      add :props, :map
      add :propval_ids, {:array, :integer}

      add :user_type, :integer, default: 0
      add :user_need, :integer, default: 0

      add :origin_src, :integer, default: 0, null: false
      add :origin_uid, :citext

      timestamps()
    end

    create unique_index(:adentries, [:slug])
    create unique_index(:adentries, [:origin_src, :origin_uid], name: "adentries_origin_index")
    create index(:adentries, [:editor_id])
    create index(:adentries, [:user_id])
    create index(:adentries, [:shop_id])

    create index(:adentries, [:status])
    create index(:adentries, [:updated_at])

    execute(
      "CREATE INDEX adentries_location_ids_index ON adentries USING GIN(location_ids gin__int_ops);"
    )

    execute(
      "CREATE INDEX adentries_grouping_ids_index ON adentries USING GIN(grouping_ids gin__int_ops);"
    )

    execute(
      "CREATE INDEX adentries_propval_ids_index ON adentries USING GIN(propval_ids gin__int_ops);"
    )

    execute(
      "CREATE INDEX adentries_image_ids_index ON adentries USING GIN(image_ids gin__int_ops);"
    )
  end
end
