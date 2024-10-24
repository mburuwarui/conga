defmodule Conga.Accounts.User do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication, AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "user"

    routes do
      base "/users"

      get :read
      post :create
    end
  end

  graphql do
    type :user

    queries do
      get :get_user, :read
    end
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
      end
    end

    tokens do
      enabled? true
      token_resource Conga.Accounts.Token
      signing_secret Conga.Accounts.Secrets
    end
  end

  postgres do
    table "users"
    repo Conga.Repo
  end

  code_interface do
    define :update_admin
    define :update_author
    define :update_user
  end

  actions do
    defaults [:read, :destroy, create: [], update: []]

    update :update_admin do
      change set_attribute(:role, :admin)
    end

    update :update_author do
      change set_attribute(:role, :author)
    end

    update :update_user do
      change set_attribute(:role, :user)
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :author)
      authorize_if actor_attribute_equals(:role, :user)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    attribute :role, :atom do
      constraints one_of: [:admin, :author, :user]
      default :user
      public? true
      description "The role of the user"
    end

    timestamps()
  end

  relationships do
    has_many :posts, Conga.Posts.Post
    has_many :comments, Conga.Posts.Comment
    has_many :likes, Conga.Posts.Like
    has_many :bookmarks, Conga.Posts.Bookmark
    has_many :accounts, Conga.Accounts.Account
    has_one :profile, Conga.Accounts.Profile
  end

  identities do
    identity :unique_email, [:email]
  end
end
