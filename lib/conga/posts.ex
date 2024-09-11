defmodule Conga.Posts do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Conga.Posts.Post
    resource Conga.Posts.Comment
    resource Conga.Posts.Like
    resource Conga.Posts.Bookmark
  end
end
