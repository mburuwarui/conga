defmodule Conga.Posts.PostCategory do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "post_category"

    routes do
      base "/post_categories"

      get :read
    end

    primary_key do
      keys [:post_id, :category_id]
    end
  end

  graphql do
    type :post_category
  end

  postgres do
    table "post_categories"
    repo Conga.Repo

    references do
      reference :post do
        on_delete :delete
      end

      reference :category do
        on_delete :delete
      end
    end
  end

  resource do
    description "A join table for category of a post"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      upsert? true
      upsert_identity :unique_post_category
    end
  end

  relationships do
    belongs_to :post, Conga.Posts.Post do
      public? true
      primary_key? true
      allow_nil? false
    end

    belongs_to :category, Conga.Posts.Category do
      public? true
      primary_key? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_post_category, [:post_id, :category_id]
  end
end
