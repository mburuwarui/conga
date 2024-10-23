defmodule Conga.Accounts.TransferType do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "transfer_type"
  end

  graphql do
    type :transfer_type

    queries do
      get :get_transfer_type, :read
      list :list_transfer_types, :read
    end
  end

  postgres do
    table "transfer_types"
    repo Conga.Repo
  end

  resource do
    description "Mapping for transfer types in the system"
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      argument :code, :integer do
        allow_nil? false
        constraints min: 0
      end

      accept [:name]
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
      description "The integer code representing the transfer type"
    end

    attribute :name, :string do
      allow_nil? false
      public? true
      description "The string representation of the transfer type"
    end

    timestamps()
  end

  identities do
    identity :unique_code, [:code]
  end
end
