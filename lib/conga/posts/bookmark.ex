defmodule Conga.Posts.Bookmark do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "bookmark"
  end

  graphql do
    type :bookmark
  end

  postgres do
    table "bookmarks"
    repo Conga.Repo
  end

  resource do
    description "A bookmark of a post by a user"
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    create :bookmark_post do
      accept [:notes]

      argument :post_id, :uuid do
        allow_nil? false
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:post_id, :post, type: :append)
      change manage_relationship(:user_id, :user, type: :append)
    end

    update :update_notes do
      accept [:notes]
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type([:update, :destroy]) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "bookmark"

    publish_all :create, ["bookmarks"]
    publish_all :update, ["bookmarks"]
    publish_all :destroy, ["bookmarks"]
  end

  attributes do
    uuid_primary_key :id

    attribute :notes, :string do
      public? true
      description "Optional notes for the bookmark"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Conga.Accounts.User do
      public? true
      allow_nil? false
    end

    belongs_to :post, Conga.Posts.Post do
      public? true
      allow_nil? false
    end
  end
end
