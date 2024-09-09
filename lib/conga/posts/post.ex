defmodule Conga.Posts.Post do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

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

  actions do
    defaults [:read, :destroy, create: [:text], update: [:text]]
  end

  attributes do
    uuid_primary_key :id

    attribute :text, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Conga.Accounts.User do
      public? true
    end
  end
end
