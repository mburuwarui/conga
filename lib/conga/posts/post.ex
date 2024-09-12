defmodule Conga.Posts.Post do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "post"
  end

  graphql do
    type :post
  end

  postgres do
    table "posts"
    repo Conga.Repo
  end

  resource do
    description "A blog post with extended features and policies"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :body, :category, :visibility]

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:user_id, :user, type: :append)
    end

    update :update do
      accept [:title, :body, :category, :visibility]
    end

    read :list_public do
      filter expr(visibility == :public)
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(visibility == :public)
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type(:update) do
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type(:destroy) do
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
      description "The title of the blog post"
    end

    attribute :body, :string do
      allow_nil? false
      public? true
      description "The main content of the blog post"
    end

    attribute :category, :string do
      allow_nil? false
      public? true
      description "The category of the blog post"
    end

    attribute :visibility, :atom do
      constraints one_of: [:public, :private, :friends]
      default :public
      public? true
      description "Visibility setting for the post"
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Conga.Accounts.User do
      public? true
      allow_nil? false
    end

    has_many :comments, Conga.Posts.Comment
    has_many :likes, Conga.Posts.Like
    has_many :bookmarks, Conga.Posts.Bookmark
  end

  calculations do
    calculate :total_likes, :integer, expr(count(likes))
    calculate :total_bookmarks, :integer, expr(count(bookmarks))
    calculate :total_comments, :integer, expr(count(comments))
    calculate :popularity_score, :float, expr(total_likes * 2 + total_comments + total_bookmarks)
    calculate :reading_time, :integer, expr(string_length(body) / 200)
  end

  aggregates do
    count :like_count, :likes
    count :comment_count, :comments
    count :bookmark_count, :bookmarks
  end

  pub_sub do
    module CongaWeb.Endpoint
    prefix "post"
    publish_all :create, ["posts"]
    publish_all :update, ["posts"]
    publish_all :destroy, ["posts"]
  end
end
