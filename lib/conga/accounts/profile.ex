defmodule Conga.Accounts.Profile do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "profile"

    routes do
      base "/profiles"

      get :read
      post :create
    end
  end

  graphql do
    type :profile

    queries do
      get :get_profile, :read
    end
  end

  postgres do
    table "profiles"
    repo Conga.Repo

    references do
      reference :user do
        on_delete :delete
      end
    end
  end

  resource do
    description "A profile of a user"
  end

  code_interface do
    define :create
    define :read
    define :list_all
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_user

      accept [:first_name, :last_name, :occupation]

      argument :user_id, :uuid do
        allow_nil? false
      end

      argument :profile_picture, :string do
        allow_nil? false
      end

      change manage_relationship(:user_id, :user, type: :append)
      change set_attribute(:avatar, arg(:profile_picture))
    end

    update :update do
      primary? true

      accept [:first_name, :last_name, :occupation]

      argument :profile_picture, :string

      change set_attribute(:avatar, arg(:profile_picture))
    end

    read :list_all do
      prepare build(sort: [inserted_at: :desc])
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:update) do
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type(:destroy) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string do
      allow_nil? false
      public? true
      description "The first name of the user"
    end

    attribute :last_name, :string do
      allow_nil? false
      public? true
      description "The last name of the user"
    end

    attribute :occupation, :string do
      allow_nil? false
      public? true
      description "The occupation of the user"
    end

    attribute :avatar, :string do
      public? true
      description "The avatar of the user"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Conga.Accounts.User do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_user, [:user_id]
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "profile"

    publish_all :create, ["profiles"]
    publish_all :update, ["profiles"]
    publish_all :destroy, ["profiles"]
  end
end
