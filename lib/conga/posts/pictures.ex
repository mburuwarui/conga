defmodule Conga.Posts.Pictures do
  use Ash.Resource,
    otp_app: :conga,
    domain: Conga.Posts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  import Ash.Notifier.PubSub

  json_api do
    type "picture"
  end

  graphql do
    type :picture

    queries do
      get :get_picture, :read
    end
  end

  postgres do
    table "pictures"
    repo Conga.Repo

    references do
      reference :user do
        on_delete :delete
      end

      reference :post do
        on_delete :delete
      end
    end
  end

  resource do
    description "A picture on a blog post"
  end

  code_interface do
    define :list_pictures
    define :new_picture, args: [:post_id, :url]
  end

  actions do
    defaults [:read, :destroy, :update]

    create :new_picture do
      primary? true

      accept [:url]

      change set_attribute(:post_id, arg(:post_id))
      change relate_actor(:user)
    end

    read :list_pictures do
      prepare build(
                sort: [inserted_at: :desc],
                filter: expr(is_approved == true)
              )
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action(:approve) do
      authorize_if actor_attribute_equals(:role, :moderator)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :url, :string do
      allow_nil? false
      public? true
      description "The picture of the blog post"
    end

    attribute :is_approved, :boolean do
      default true
      public? true
      description "Whether the picture has been approved by a moderator"
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
    prefix "add_picture"

    publish_all :create, ["pictures"]
    publish_all :destroy, ["pictures"]
  end
end
