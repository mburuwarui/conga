[
  import_deps: [
    :ash_json_api,
    :ash_graphql,
    :absinthe,
    :ash_postgres,
    :ash,
    :ash_authentication,
    :ash_authentication_phoenix,
    :ecto,
    :ecto_sql,
    :phoenix
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [Absinthe.Formatter, Spark.Formatter, Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
