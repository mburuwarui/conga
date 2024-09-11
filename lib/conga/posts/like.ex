defmodule Conga.Posts.Like do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "like"
  end

  graphql do
    type :like
  end

  postgres do
    table "likes"
    repo Conga.Repo
  end

  resource do
    description "A like on a post or comment"
  end

  actions do
    defaults [:create, :read, :destroy]

    create :like_post do
      accept []

      argument :post_id, :uuid do
        allow_nil? false
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:post_id, :post, type: :append)
      change manage_relationship(:user_id, :user, type: :append)
    end

    create :like_comment do
      accept []

      argument :comment_id, :uuid do
        allow_nil? false
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:comment_id, :comment, type: :append)
      change manage_relationship(:user_id, :user, type: :append)
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:destroy) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, Conga.Accounts.User do
      public? true
      allow_nil? false
    end

    belongs_to :post, Conga.Posts.Post do
      public? true
      allow_nil? true
    end

    belongs_to :comment, Conga.Posts.Comment do
      public? true
      allow_nil? true
    end
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "like"

    publish_all :create, ["likes"]
    publish_all :destroy, ["likes"]
  end
end
