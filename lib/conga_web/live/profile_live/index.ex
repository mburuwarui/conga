defmodule CongaWeb.ProfileLive.Index do
  use CongaWeb, :live_view

  import SaladUI.Button

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing profile
      <:actions>
        <.link :if={is_nil(@profile)} patch={~p"/profile/new"}>
          <.button>Add profile</.button>
        </.link>
        <.link phx-click="update_admin">
          <.button>Update role</.button>
        </.link>
      </:actions>
    </.header>

    <.table_core
      id="profiles"
      rows={@streams.profiles}
      row_click={fn {_id, profile} -> JS.navigate(~p"/profile/#{profile}") end}
    >
      <:col :let={{_id, profile}} label="Id"><%= profile.id %></:col>

      <:col :let={{_id, profile}} label="First Name"><%= profile.first_name %></:col>

      <:col :let={{_id, profile}} label="Last Name"><%= profile.last_name %></:col>

      <:col :let={{_id, profile}} label="Occupation"><%= profile.occupation %></:col>

      <:col :let={{_id, profile}} label="Avatar">
        <img src={profile.avatar} class="rounded-md" />
      </:col>

      <:action :let={{_id, profile}}>
        <div class="sr-only">
          <.link navigate={~p"/profile/#{profile}"}>Show</.link>
        </div>

        <.link patch={~p"/profile/#{profile}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, profile}}>
        <.link
          phx-click={JS.push("delete", value: %{id: profile.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table_core>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="profile-modal"
      show
      on_cancel={JS.patch(~p"/profile")}
    >
      <.live_component
        module={CongaWeb.ProfileLive.FormComponent}
        id={(@profile && @profile.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        profile={@profile}
        patch={~p"/profile"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:profiles, [])
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit profile")
    |> assign(:profile, Ash.get!(Conga.Accounts.Profile, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New profile")
    |> assign(:profile, nil)
  end

  defp apply_action(socket, :index, _params) do
    profiles =
      Conga.Accounts.Profile.read!(actor: socket.assigns.current_user)

    profile = Enum.find(profiles, &(&1.user_id == socket.assigns.current_user.id))

    socket
    |> assign(:page_title, "Listing profiles")
    |> assign(:profile, profile)
    |> stream(:profiles, profiles)
    |> assign(:profiles, profiles)
  end

  @impl true
  def handle_info({CongaWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    profile = Ash.get!(Conga.Accounts.Profile, id, actor: socket.assigns.current_user)
    Ash.destroy!(profile, actor: socket.assigns.current_user)

    {:noreply,
     socket
     |> stream_delete(:profiles, profile)
     |> assign(:profile, nil)
     |> put_flash(:info, "Profile deleted successfully.")}
  end

  def handle_event("update_admin", _params, socket) do
    Conga.Accounts.User
    |> Ash.get!(socket.assigns.current_user.id, actor: socket.assigns.current_user)
    |> Conga.Accounts.User.update_author!(actor: socket.assigns.current_user)

    profiles = socket.assigns.profiles

    {:noreply,
     socket
     |> stream(:profiles, profiles)
     |> put_flash(:info, "Role updated successfully.")}
  end
end
