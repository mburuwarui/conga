defmodule Conga.Accounts.Account do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "account"
  end

  graphql do
    type :account

    queries do
      get :get_account, :read
      list :list_accounts, :read
    end
  end

  postgres do
    table "accounts"
    repo Conga.Repo

    references do
      reference :user do
        on_delete :restrict
      end

      reference :ledger do
        on_delete :restrict
      end
    end
  end

  resource do
    description "An account in the system"
  end

  code_interface do
    define :create
    define :read
    define :get_balance
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:flags]

      argument :user_id, :uuid do
        allow_nil? false
      end

      argument :ledger_id, :uuid do
        allow_nil? false
      end

      argument :account_type_code, :integer do
        allow_nil? false
      end

      change manage_relationship(:user_id, :user, type: :append)
      change manage_relationship(:ledger_id, :ledger, type: :append)
      change manage_relationship(:account_type_code, :account_type, type: :append)
    end

    read :get_balance do
      argument :id, :uuid do
        allow_nil? false
      end

      filter expr(id == ^arg(:id))
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :balance, :integer do
      default 0
      public? true
      description "Current balance of the account"
    end

    attribute :flags, :integer do
      default 0
      public? true
      description "Account flags for TigerBeetle"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Conga.Accounts.User do
      public? true
      allow_nil? false
    end

    belongs_to :ledger, Conga.Accounts.Ledger do
      public? true
      allow_nil? false
    end

    belongs_to :account_type, Conga.Accounts.AccountType do
      attribute_type :integer
      source_attribute :account_type_code
      destination_attribute :code
      public? true
      allow_nil? false
    end

    has_many :debit_transfers, Conga.Accounts.Transfer do
      destination_attribute :debit_account_id
    end

    has_many :credit_transfers, Conga.Accounts.Transfer do
      destination_attribute :credit_account_id
    end
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "account"
    publish_all :create, ["accounts"]
    publish :update, ["account", :id, "updated"]
  end
end
