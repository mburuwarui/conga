defmodule Conga.Repo.Migrations.UniqueUserProfile do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create unique_index(:profiles, [:user_id], name: "profiles_unique_user_index")
  end

  def down do
    drop_if_exists unique_index(:profiles, [:user_id], name: "profiles_unique_user_index")
  end
end
