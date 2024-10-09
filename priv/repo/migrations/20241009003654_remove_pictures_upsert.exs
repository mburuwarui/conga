defmodule Conga.Repo.Migrations.RemovePicturesUpsert do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:pictures) do
      add :user_id,
          references(:users,
            column: :id,
            name: "pictures_user_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false
    end

    drop_if_exists unique_index(:pictures, [:url], name: "pictures_unique_url_index")
  end

  def down do
    drop constraint(:pictures, "pictures_user_id_fkey")

    create unique_index(:pictures, [:url], name: "pictures_unique_url_index")

    alter table(:pictures) do
      remove :user_id
    end
  end
end
