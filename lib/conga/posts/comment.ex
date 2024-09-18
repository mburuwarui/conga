defmodule Conga.Posts.Comment do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "comment"
  end

  graphql do
    type :comment

    queries do
      get :get_comment, :read
    end
  end

  postgres do
    table "comments"
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
    description "A comment on a blog post"
  end

  code_interface do
    define :create_child_comment, args: [:post_id, :comment_id]
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:content]

      argument :post_id, :uuid do
        allow_nil? false
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:post_id, :post, type: :append)
      change manage_relationship(:user_id, :user, type: :append)
    end

    create :create_child_comment do
      accept [:content]
      upsert? true
      upsert_identity :unique_user_comment_and_post

      argument :post_id, :uuid do
        allow_nil? false
      end

      argument :comment_id, :uuid do
        allow_nil? false
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change set_attribute(:post_id, arg(:post_id))
      change set_attribute(:comment_id, arg(:comment_id))

      change relate_actor(:user)
    end

    update :update do
      accept [:content]
      change set_attribute(:is_approved, true)
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if expr(is_approved == true)
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type([:update, :destroy]) do
      authorize_if relates_to_actor_via(:user)
    end

    policy action(:approve) do
      authorize_if actor_attribute_equals(:role, :moderator)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :content, :string do
      allow_nil? false
      public? true
      description "The content of the comment"
    end

    attribute :is_approved, :boolean do
      default true
      public? true
      description "Whether the comment has been approved by a moderator"
    end

    timestamps()
  end

  relationships do
    belongs_to :post, Conga.Posts.Post do
      public? true
      allow_nil? false
    end

    belongs_to :comment, Conga.Posts.Comment do
      public? true
      allow_nil? true
    end

    has_many :comments, Conga.Posts.Comment

    belongs_to :user, Conga.Accounts.User do
      public? true
      allow_nil? false
    end

    has_many :likes, Conga.Posts.Like
  end

  aggregates do
    count :like_count, :likes
  end

  identities do
    identity :unique_user_comment_and_post, [:user_id, :post_id, :comment_id]
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "comment"

    publish_all :create, ["comments"]
    publish_all :update, ["comments"]
    publish_all :destroy, ["comments"]
    publish :approve, ["comment", :id, "approved"]
  end
end
