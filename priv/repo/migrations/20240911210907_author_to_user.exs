defmodule Conga.Repo.Migrations.AuthorToUser do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    rename table(:posts), :author_id, to: :user_id

    drop constraint(:posts, "posts_author_id_fkey")

    alter table(:posts) do
      modify :user_id,
             references(:users,
               column: :id,
               name: "posts_user_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    rename table(:comments), :author_id, to: :user_id

    drop constraint(:comments, "comments_author_id_fkey")

    alter table(:comments) do
      modify :user_id,
             references(:users,
               column: :id,
               name: "comments_user_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    execute("ALTER TABLE comments alter CONSTRAINT comments_user_id_fkey NOT DEFERRABLE")

    execute("ALTER TABLE posts alter CONSTRAINT posts_user_id_fkey NOT DEFERRABLE")
  end

  def down do
    drop constraint(:comments, "comments_user_id_fkey")

    alter table(:comments) do
      modify :author_id,
             references(:users,
               column: :id,
               name: "comments_author_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    rename table(:comments), :user_id, to: :author_id

    drop constraint(:posts, "posts_user_id_fkey")

    alter table(:posts) do
      modify :author_id,
             references(:users,
               column: :id,
               name: "posts_author_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    rename table(:posts), :user_id, to: :author_id
  end
end