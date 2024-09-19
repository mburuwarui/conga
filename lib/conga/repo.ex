defmodule Conga.Repo do
  use AshPostgres.Repo,
    otp_app: :conga

  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions", "citext", "uuid-ossp", "timescaledb"]
  end

  def min_pg_version do
    # Adjust this according to your postgres version
    %Version{major: 16, minor: 0, patch: 0}
  end
end
