defmodule Conga.Posts.Reaction do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "reaction"
  end

  graphql do
    type :reaction
  end

  postgres do
    table "reactions"
    repo Conga.Repo
  end

  resource do
    description "A reaction to a post"
  end

  actions do
    defaults [:create, :read, :destroy]

    create :react do
      argument :type, :atom do
        allow_nil? false
        constraints one_of: Conga.Posts.ReactionType.all()
      end

      argument :post_id, :uuid do
        allow_nil? false
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:post_id, :post, type: :append)
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

    policy action_type([:update, :destroy]) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :type, :atom do
      constraints one_of: Conga.Posts.ReactionType.all()
      allow_nil? false
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

  pub_sub do
    module CongaWeb.Endpoint
    prefix "reaction"

    publish_all :create, ["reactions"]
    publish_all :update, ["reactions"]
    publish_all :destroy, ["reactions"]
  end
end
