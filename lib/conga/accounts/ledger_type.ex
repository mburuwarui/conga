defmodule Conga.Accounts.LedgerType do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "ledger_type"
  end

  graphql do
    type :ledger_type

    queries do
      get :get_ledger_type, :read
      list :list_ledger_types, :read
    end
  end

  postgres do
    table "ledger_types"
    repo Conga.Repo
  end

  resource do
    description "Mapping for ledger types in the system"
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      argument :code, :integer do
        allow_nil? false
        constraints min: 0
      end

      accept [:name, :asset_scale]
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :code, :integer do
      allow_nil? false
      constraints min: 0
      public? true
      description "The integer code representing the ledger type"
    end

    attribute :name, :string do
      allow_nil? false
      public? true
      description "The string representation of the ledger type"
    end

    attribute :asset_scale, :integer do
      allow_nil? false
      constraints min: 0
      public? true
      description "The scale factor for the asset in this ledger"
    end

    timestamps()
  end

  identities do
    identity :unique_code, [:code]
  end
end
