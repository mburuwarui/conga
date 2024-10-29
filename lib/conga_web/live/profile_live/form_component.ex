defmodule CongaWeb.ProfileLive.FormComponent do
  use CongaWeb, :live_component
  import SaladUI.Button
  # import SaladUI.Input
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage profile records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input_core field={@form[:first_name]} label="First Name" />
        <.input_core field={@form[:last_name]} label="Last Name" />
        <.input_core field={@form[:occupation]} label="Occupation" />
        <.live_file_input upload={@uploads.profile_picture} />
        <%= for entry <- @uploads.profile_picture.entries do %>
          <article class="upload-entry">
            <figure>
              <.live_img_preview entry={entry} />
              <figcaption><%= entry.client_name %></figcaption>
            </figure>

            <%!-- entry.progress will update automatically for in-flight entries --%>
            <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

            <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
            >
              &times;
            </button>

            <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
            <%= for err <- upload_errors(@uploads.profile_picture, entry) do %>
              <p class="alert alert-danger"><%= inspect(err) %></p>
            <% end %>
          </article>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded_files, [])
     |> allow_upload(:profile_picture,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       external: &presign_upload/2
     )
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"profile" => profile_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, profile_params))}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :profile_picture, ref)}
  end

  @impl true
  def handle_event("save", %{"profile" => profile_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :profile_picture, fn %{key: key}, _entry ->
        {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{key}"}
      end)

    IO.inspect(uploaded_files, label: "uploaded_files")

    profile_params =
      profile_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("profile_picture", List.first(uploaded_files))

    IO.inspect(profile_params, label: "profile_params")

    IO.inspect(List.first(uploaded_files), label: "uploaded_file")

    case AshPhoenix.Form.submit(socket.assigns.form, params: profile_params) do
      {:ok, profile} ->
        notify_parent({:saved, profile})

        socket =
          socket
          |> put_flash(:info, "Profile #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{profile: profile}} = socket) do
    IO.inspect(profile, label: "assign_form_profile")

    form =
      if profile do
        AshPhoenix.Form.for_update(profile, :update,
          forms: [auto?: true],
          as: "profile",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Conga.Accounts.Profile, :create,
          as: "profile",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  defp presign_upload(entry, socket) do
    filename = "#{entry.client_name}"
    key = "public/profile_pictures/#{Nanoid.generate()}-#{filename}"

    config = %{
      region: "auto",
      access_key_id: System.get_env("CLOUDFLARE_R2_ACCESS_KEY_ID"),
      secret_access_key: System.get_env("CLOUDFLARE_R2_SECRET_ACCESS_KEY"),
      url:
        "https://#{System.get_env("CLOUDFLARE_BUCKET_NAME")}.#{System.get_env("CLOUDFLARE_ACCOUNT_ID")}.r2.cloudflarestorage.com"
    }

    IO.inspect(filename, label: "filename")

    {:ok, presigned_url} =
      Conga.S3Upload.presigned_put(config,
        key: key,
        content_type: entry.client_type,
        max_file_size: socket.assigns.uploads[entry.upload_config].max_file_size
      )

    IO.inspect(presigned_url, label: "presigned_url")

    meta = %{
      uploader: "S3",
      key: key,
      url: presigned_url
    }

    IO.inspect(meta, label: "meta")

    {:ok, meta, socket}
  end
end
