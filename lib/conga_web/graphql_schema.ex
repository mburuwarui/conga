defmodule CongaWeb.GraphqlSchema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [Conga.Accounts, Conga.Posts]

  import_types(Absinthe.Plug.Types)

  query do
    # Custom Absinthe queries can be placed here
    @desc """
    Hello! This is a sample query to verify that AshGraphql has been set up correctly.
    Remove me once you have a query of your own!
    """
    field :say_hello, :string do
      resolve(fn _, _, _ ->
        {:ok, "Hello from AshGraphql!"}
      end)
    end
  end

  mutation do
    # Custom Absinthe mutations can be placed here
  end
end
