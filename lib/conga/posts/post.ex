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
    defaults [:create, :read, :update, :destroy]

    create :publish do
      accept [:title, :text, :category, :visibility]

      argument :author_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:author_id, :author, type: :append)

      change set_attribute(:reading_time, fn _, changes ->
               text = Map.get(changes, :text, "")

               # Rough estimate: 200 words per minute
               String.length(text) |> div(200)
             end)
    end

    update :react do
      accept []

      argument :type, :atom do
        allow_nil? false
        constraints one_of: Conga.Posts.ReactionType.all()
      end

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:user_id, :reactions,
               type: :append_and_remove,
               destination_attribute: :type,
               destination_path: [:type]
             )

      change set_attribute(:reaction_counts, fn post, changes ->
               reaction_type = changes.arguments.type
               current_counts = Map.get(post, :reaction_counts, %{})
               Map.update(current_counts, reaction_type, 1, &(&1 + 1))
             end)
    end

    read :list_public do
      filter expr(visibility == :public)
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(visibility == :public)
      authorize_if relates_to_actor_via(:author)
      authorize_if expr(relates_to_actor_via([:author, :friends]) and visibility == :friends)
    end

    policy action_type(:update) do
      authorize_if relates_to_actor_via(:author)
    end

    policy action_type(:destroy) do
      authorize_if relates_to_actor_via(:author)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
      description "The title of the blog post"
    end

    attribute :text, :string do
      allow_nil? false
      public? true
      description "The main content of the blog post"
    end

    attribute :category, :string do
      allow_nil? false
      public? true
      description "The category of the blog post"
    end

    attribute :reading_time, :integer do
      default 0
      public? true
      description "Estimated reading time in minutes"
    end

    attribute :visibility, :atom do
      constraints one_of: [:public, :private, :friends]
      default :public
      public? true
      description "Visibility setting for the post"
    end

    attribute :reaction_counts, :map do
      default %{}
      public? true
      description "counts of each reaction type"
      constraints type: {:map, {:integer}}
    end

    timestamps()
  end

  relationships do
    belongs_to :author, Conga.Accounts.User do
      public? true
      allow_nil? false
    end

    has_many :comments, Conga.Posts.Comment
    has_many :likes, Conga.Posts.Like
    has_many :bookmarks, Conga.Posts.Bookmark
  end

  calculations do
    calculate :popularity_score, :float, expr(like_count * 2 + comment_count + bookmark_count)
    calculate :total_reactions, :integer, expr(sum(values(reaction_counts)))
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
    publish :react, ["post", :id, "reaction"]
  end
end
