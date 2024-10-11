defmodule CongaWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.Components
  # alias AshAuthentication.Phoenix.SignInLive

  # override SignInLive do
  #   set :root_class, "bg-none"
  # end
  #
  # override Components.SignIn do
  #   set :root_class, "m-auto"
  # end

  override Components.Banner do
    # set :text, "Debug: Custom banner should appear here"
    set :image_url, "/images/logo.jpg"
    set :dark_image_url, "/images/logo.jpg"
    set :image_class, "w-32 h-auto rounded-full"
    # set :dark_image_class, "w-32 h-auto rounded-full"
    set :root_class, "p-4 flex justify-center items-center"
    set :href_url, "/posts"
  end
end
