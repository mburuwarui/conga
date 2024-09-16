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

    references do
      reference :user do
        on_delete :delete
      end

      reference :post do
        on_delete :delete
      end

      reference :comment do
        on_delete :delete
      end
    end
  end

  resource do
    description "A like on a post or comment"
  end

  code_interface do
    define :like, args: [:post_id]
  end

  actions do
    defaults [:read, :destroy]

    create :like do
      upsert? true
      upsert_identity :unique_user_and_post

      argument :post_id, :uuid do
        allow_nil? false
      end

      change set_attribute(:post_id, arg(:post_id))
      change relate_actor(:user)
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

  identities do
    identity :unique_user_and_post, [:user_id, :post_id]
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "like"

    publish_all :create, ["likes"]
    publish_all :destroy, ["likes"]
  end
end
