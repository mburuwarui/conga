defmodule CongaWeb.SignInLive do
  use CongaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={AshAuthentication.Phoenix.Components.SignIn}
      id="sign-in-form"
      overrides={[
        CongaWeb.AuthOverrides,
        AshAuthentication.Phoenix.Overrides.Default
      ]}
    />
    """
  end
end
