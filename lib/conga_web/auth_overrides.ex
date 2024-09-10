defmodule CongaWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.Components

  # override Components.SignIn do
  #   set :show_banner, nil
  #   set :root_class, "auth-page"
  # end

  override Components.Banner do
    # set :text, "Debug: Custom banner should appear here"
    set :image_url, "/images/logo.svg"
    set :dark_image_url, "/images/logo.svg"
    set :image_class, "w-32 h-auto"
    set :root_class, "p-4 flex justify-center items-center"
    set :href_url, "/"
  end
end
