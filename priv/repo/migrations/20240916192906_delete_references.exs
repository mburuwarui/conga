defmodule Conga.Repo.Migrations.DeleteReferences do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint(:posts, "posts_user_id_fkey")

    alter table(:posts) do
      modify :user_id,
             references(:users,
               column: :id,
               name: "posts_user_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    execute("ALTER TABLE posts alter CONSTRAINT posts_user_id_fkey NOT DEFERRABLE")
  end

  def down do
    drop constraint(:posts, "posts_user_id_fkey")

    alter table(:posts) do
      modify :user_id,
             references(:users,
               column: :id,
               name: "posts_user_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end
  end
end
