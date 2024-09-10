defmodule CongaWeb.Router do
  use CongaWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :graphql do
    plug AshGraphql.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CongaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui",
            OpenApiSpex.Plug.SwaggerUI,
            path: "/api/json/open_api",
            default_model_expand_depth: 4

    forward "/", CongaWeb.AshJsonApiRouter
  end

  scope "/gql" do
    pipe_through [:graphql]

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: Module.concat(["CongaWeb.GraphqlSchema"]),
            interface: :playground

    forward "/",
            Absinthe.Plug,
            schema: Module.concat(["CongaWeb.GraphqlSchema"])
  end

  scope "/", CongaWeb do
    pipe_through :browser

    get "/", PageController, :home

    # add these lines -->
    # Leave out `register_path` and `reset_path` if you don't want to support
    # user registration and/or password resets respectively.
    sign_in_route(
      on_mount: [{CongaWeb.LiveUserAuth, :live_no_user}],
      register_path: "/register",
      reset_path: "/reset",
      live_view: CongaWeb.SignInLive
    )

    sign_out_route AuthController
    auth_routes_for Conga.Accounts.User, to: AuthController
    reset_route []
    # <-- add these lines

    ash_authentication_live_session :authentication_required,
      on_mount: {CongaWeb.LiveUserAuth, :live_user_required} do
      live "/posts/new", PostLive.Index, :new
      live "/posts/:id/edit", PostLive.Index, :edit

      live "/posts/:id/show/edit", PostLive.Show, :edit
    end

    ash_authentication_live_session :authentication_optional,
      on_mount: {CongaWeb.LiveUserAuth, :live_user_optional} do
      live "/posts", PostLive.Index, :index

      live "/posts/:id", PostLive.Show, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", CongaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:conga, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CongaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
