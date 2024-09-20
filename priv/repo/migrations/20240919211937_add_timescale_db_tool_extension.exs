defmodule Conga.Repo.Migrations.AddTimescaleDbToolExtension do
  use Ecto.Migration

  import Timescale.Migration

  def up do
    create_timescaledb_toolkit_extension()
  end

  def down do
    drop_timescaledb_toolkit_extension()
  end
end
