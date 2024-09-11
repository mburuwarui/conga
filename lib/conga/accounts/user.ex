defmodule Conga.Accounts.User do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Accounts,
    data_layer: AshPostgres.DataLayer,
    # If using policies, enable the policy authorizer:
    # authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication, AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "user"
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

  graphql do
    type :user
  end

  postgres do
    table "users"
    repo Conga.Repo
  end

  actions do
    defaults [:read, :destroy, create: [], update: []]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    timestamps()
  end

  relationships do
    has_many :posts, Conga.Posts.Post
    has_many :comments, Conga.Posts.Comment
    has_many :likes, Conga.Posts.Like
    has_many :bookmarks, Conga.Posts.Bookmark
  end

  identities do
    identity :unique_email, [:email]
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
