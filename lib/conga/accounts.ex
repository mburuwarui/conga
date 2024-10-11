defmodule Conga.Accounts do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Conga.Accounts.User
    resource Conga.Accounts.Token
    resource Conga.Accounts.Profile
  end
end
