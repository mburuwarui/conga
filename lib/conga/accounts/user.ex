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

  actions do
    defaults [:read, :destroy, create: []]

    update :update do
      accept [:email, :role]
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if actor_present()
      # authorize_if relates_to_actor_via(:user)
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
    has_one :profile, Conga.Accounts.Profile
  end

  identities do
    identity :unique_email, [:email]
  end
end
