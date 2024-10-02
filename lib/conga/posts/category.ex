defmodule Conga.Posts.Category do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "category"

    routes do
      base "/categories"

      get :read
      post :create
    end
  end

  graphql do
    type :category

    queries do
      get :get_category, :read
    end
  end

  postgres do
    table "categories"
    repo Conga.Repo
  end

  resource do
    description "A category of a post"
  end

  code_interface do
    define :create
    define :list_all
  end

  actions do
    defaults [:read, :destroy, :update]

    create :create do
      primary? true

      upsert? true
      upsert_identity :unique_name

      accept [:name]
    end

    read :list_all do
      prepare build(sort: [inserted_at: :desc])
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
      description "The category of the blog post"
    end

    timestamps()
  end

  relationships do
    many_to_many :posts, Conga.Posts.Post do
      through Conga.Posts.PostCategory
      source_attribute_on_join_resource :category_id
      destination_attribute_on_join_resource :post_id
      public? true
    end
  end

  identities do
    identity :unique_name, [:name]
  end
end
