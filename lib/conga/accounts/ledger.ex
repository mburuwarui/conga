defmodule Conga.Accounts.Ledger do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "ledger"
  end

  graphql do
    type :ledger

    queries do
      get :get_ledger, :read
      list :list_ledgers, :read
    end
  end

  postgres do
    table "ledgers"
    repo Conga.Repo

    references do
      reference :ledger_type do
        on_delete :restrict
      end
    end
  end

  resource do
    description "A ledger in the system"
  end

  code_interface do
    define :create
    define :read
    define :by_code
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:name, :description]

      argument :ledger_type_code, :integer do
        allow_nil? false
      end

      change manage_relationship(:ledger_type_code, :ledger_type, type: :append)
    end

    read :by_code do
      argument :ledger_type_code, :integer do
        allow_nil? false
      end

      filter expr(ledger_type_code == ^arg(:ledger_type_code))
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

    attribute :name, :string do
      allow_nil? false
      public? true
      description "The name of the ledger"
    end

    attribute :description, :string do
      public? true
      description "Description of the ledger's purpose"
    end

    timestamps()
  end

  relationships do
    belongs_to :ledger_type, Conga.Accounts.LedgerType do
      attribute_type :integer
      source_attribute :ledger_type_code
      destination_attribute :code
      public? true
      allow_nil? false
    end

    has_many :accounts, Conga.Accounts.Account
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "ledger"
    publish_all :create, ["ledgers"]
    publish_all :update, ["ledgers"]
  end
end
