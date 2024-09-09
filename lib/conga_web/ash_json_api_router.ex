defmodule CongaWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["Conga.Accounts"]), Module.concat(["Conga.Posts"])],
    open_api: "/open_api"
end
