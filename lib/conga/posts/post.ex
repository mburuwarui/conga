defmodule Conga.Posts.Post do
  require Ecto.Query

  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "post"

    routes do
      base "/posts"

      get :read
      post :create
    end
  end

  graphql do
    type :post

    queries do
      get :get_post, :read
    end
  end

  postgres do
    table "posts"
    repo Conga.Repo

    references do
      reference :user do
        on_delete :delete
      end
    end
  end

  resource do
    description "A blog post with extended features and policies"
  end

  code_interface do
    define :like
    define :dislike
    define :unbookmark
    define :bookmark
    define :inc_page_views
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
      primary? true
      accept [:title, :body, :category, :visibility]
    end

    update :like do
      accept []

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Conga.Posts.Like.like(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :dislike do
      accept []

      manual fn changeset, %{actor: actor} ->
        like =
          Ecto.Query.from(like in Conga.Posts.Like,
            where: like.user_id == ^actor.id,
            where: like.post_id == ^changeset.data.id
          )

        Conga.Repo.delete_all(like)

        {:ok, changeset.data}
      end
    end

    update :bookmark do
      accept []

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Conga.Posts.Bookmark.bookmark_post(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :unbookmark do
      accept []

      manual fn changeset, %{actor: actor} ->
        bookmark =
          Ecto.Query.from(like in Conga.Posts.Bookmark,
            where: like.user_id == ^actor.id,
            where: like.post_id == ^changeset.data.id
          )

        Conga.Repo.delete_all(bookmark)

        {:ok, changeset.data}
      end
    end

    update :inc_page_views do
      accept []

      change increment(:page_views, amount: 1)
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

    attribute :page_views, :integer do
      default 0
      public? true
      description "The number of views for the post"
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

    calculate :liked_by_user, :boolean, expr(exists(likes, user_id: ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? true
      end
    end

    calculate :bookmarked_by_user, :boolean, expr(exists(bookmarks, user_id: ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? true
      end
    end
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
