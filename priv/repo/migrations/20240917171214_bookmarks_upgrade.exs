defmodule Conga.Repo.Migrations.BookmarksUpgrade do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:bookmarks) do
      remove :notes
    end

    create unique_index(:bookmarks, [:user_id, :post_id],
             name: "bookmarks_unique_user_and_post_index"
           )
  end

  def down do
    drop_if_exists unique_index(:bookmarks, [:user_id, :post_id],
                     name: "bookmarks_unique_user_and_post_index"
                   )

    alter table(:bookmarks) do
      add :notes, :text
    end
  end
end