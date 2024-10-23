defmodule Conga.Accounts.Transfer do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "transfer"
  end

  graphql do
    type :transfer

    queries do
      get :get_transfer, :read
      list :list_transfers, :read
    end
  end

  postgres do
    table "transfers"
    repo Conga.Repo

    references do
      reference :debit_account do
        on_delete :restrict
      end

      reference :credit_account do
        on_delete :restrict
      end
    end
  end

  resource do
    description "A transfer between accounts"
  end

  code_interface do
    define :create
    define :read
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:amount, :flags]

      argument :debit_account_id, :uuid do
        allow_nil? false
      end

      argument :credit_account_id, :uuid do
        allow_nil? false
      end

      argument :transfer_type_code, :integer do
        allow_nil? false
      end

      argument :pending_id, :uuid

      change manage_relationship(:debit_account_id, :debit_account, type: :append)
      change manage_relationship(:credit_account_id, :credit_account, type: :append)
      change manage_relationship(:transfer_type_code, :transfer_type, type: :append)
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if relates_to_actor_via([:debit_account, :user])
      authorize_if relates_to_actor_via([:credit_account, :user])
    end

    policy action_type(:create) do
      authorize_if relates_to_actor_via([:debit_account, :user])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :amount, :integer do
      allow_nil? false
      constraints min: 0
      public? true
      description "Amount to transfer"
    end

    attribute :flags, :integer do
      default 0
      public? true
      description "Transfer flags for TigerBeetle"
    end

    attribute :pending_id, :uuid do
      public? true
      description "ID of pending transfer if this is a settlement"
    end

    timestamps()
  end

  relationships do
    belongs_to :debit_account, Conga.Accounts.Account do
      public? true
      allow_nil? false
    end

    belongs_to :credit_account, Conga.Accounts.Account do
      public? true
      allow_nil? false
    end

    belongs_to :transfer_type, Conga.Accounts.TransferType do
      attribute_type :integer
      source_attribute :transfer_type_code
      destination_attribute :code
      public? true
      allow_nil? false
    end
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "transfer"
    publish_all :create, ["transfers"]
    publish :update, ["transfer", :id, "completed"]
  end
end
