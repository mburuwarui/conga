defmodule Conga.Repo.Migrations.LikeStatus do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:likes) do
      add :status, :boolean, default: false
    end
  end

  def down do
    alter table(:likes) do
      remove :status
    end
  end
end