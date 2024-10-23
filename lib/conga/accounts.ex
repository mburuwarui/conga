defmodule Conga.Accounts do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Conga.Accounts.User
    resource Conga.Accounts.Token
    resource Conga.Accounts.Profile

    # OLTP resources
    resource Conga.Accounts.Ledger
    resource Conga.Accounts.Account
    resource Conga.Accounts.Transfer
    resource Conga.Accounts.LedgerType
    resource Conga.Accounts.AccountType
    resource Conga.Accounts.TransferType
  end
end
