defmodule Conga.Posts do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Conga.Posts.Post
  end
end
