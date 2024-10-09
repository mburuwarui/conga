defmodule CongaWeb.PostLive.FormComponent do
  use CongaWeb, :live_component
  import SaladUI.Button
  # import SaladUI.Input
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input_core field={@form[:title]} label="Title" />
        <.input_core field={@form[:body]} label="Body" />
        <%!-- <.input_core field={@form[:category]} label="Category" /> --%>
        <.input_core field={@form[:visibility]} label="Visibility" />
        <.live_file_input upload={@uploads.post_picture} />
        <%= for entry <- @uploads.post_picture.entries do %>
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
            <%= for err <- upload_errors(@uploads.post_picture, entry) do %>
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
     |> allow_upload(:post_picture,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       external: &presign_upload/2
     )
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, post_params))}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :post_picture, ref)}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :post_picture, fn %{key: key}, _entry ->
        {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{key}"}
      end)

    IO.inspect(uploaded_files, label: "uploaded_files")

    #   consume_uploaded_entries(socket, :post_picture, fn %{path: path}, _entry ->
    #     dest = Path.join(Application.app_dir(:conga, "priv/static/uploads"), Path.basename(path))
    #     # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
    #     File.cp!(path, dest)
    #     {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    #   end)

    post_params =
      Map.put(post_params, "user_id", socket.assigns.current_user.id)
      |> Map.put("categories", [
        %{"name" => "Podcast"},
        %{"name" => "Blog"}
      ])
      # |> Map.put("add_category", %{"name" => "Blog"})
      |> Map.put("pictures", [
        %{"url" => List.first(uploaded_files)}
      ])

    IO.inspect(post_params, label: "post_params")

    IO.inspect(List.first(uploaded_files), label: "uploaded_file")

    case AshPhoenix.Form.submit(socket.assigns.form, params: post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        socket =
          socket
          |> put_flash(:info, "Post #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply,
         socket
         # |> assign(:uploaded_files, uploaded_files)
         |> assign(form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{post: post}} = socket) do
    IO.inspect(post, label: "assign_form_post")

    form =
      if post do
        AshPhoenix.Form.for_update(post, :update,
          as: "post",
          actor: socket.assigns.current_user
        )

        AshPhoenix.Form.for_update(post, :update_categories,
          as: "post",
          actor: socket.assigns.current_user
        )

        AshPhoenix.Form.for_update(post, :update_pictures,
          as: "post",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Conga.Posts.Post, :create,
          as: "post",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  defp presign_upload(entry, socket) do
    filename = "#{entry.client_name}"
    key = "public/#{Nanoid.generate()}-#{filename}"

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
