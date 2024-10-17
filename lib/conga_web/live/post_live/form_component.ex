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
        <:subtitle>Use this form to manage notebook records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input_core field={@form[:title]} label="Title" />
        <.input_core field={@form[:body]} type="textarea" label="Body" />
        <.input_core field={@form[:visibility]} label="Visibility" />

        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">Categories</label>
          <%= for category <- @available_categories do %>
            <div class="flex items-center">
              <.input_core
                field={@form[:categories]}
                type="checkbox"
                checked={category.name in @selected_categories}
                label={category.name}
                phx-click="toggle_category"
                phx-value-name={category.name}
                phx-target={@myself}
              />
            </div>
          <% end %>
        </div>

        <.live_file_input upload={@uploads.post_picture} />
        <%= for entry <- @uploads.post_picture.entries do %>
          <article class="upload-entry">
            <figure>
              <.live_img_preview entry={entry} />
              <figcaption><%= entry.client_name %></figcaption>
            </figure>

            <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
            >
              &times;
            </button>

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
     |> assign(:available_categories, Conga.Posts.Category.list_all!())
     |> assign(:selected_categories, get_selected_categories(assigns.post))
     |> allow_upload(:post_picture,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       external: &presign_upload/2
     )
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    categories =
      case Map.get(post_params, "categories") do
        nil -> []
        categories when is_list(categories) -> categories
        categories when is_binary(categories) -> [categories]
        _ -> []
      end
      |> Enum.map(fn category ->
        if is_binary(category) do
          %{name: category}
        else
          category
        end
      end)

    post_params =
      post_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("categories", categories)

    form =
      socket.assigns.form
      |> AshPhoenix.Form.validate(post_params)
      |> AshPhoenix.Form.update_options(fn options ->
        Keyword.put(options, :selected_categories, socket.assigns.selected_categories)
      end)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :post_picture, ref)}
  end

  def handle_event("toggle_category", %{"name" => category_name}, socket) do
    selected_categories =
      if category_name in socket.assigns.selected_categories do
        List.delete(socket.assigns.selected_categories, category_name)
      else
        [category_name | socket.assigns.selected_categories]
      end

    form =
      AshPhoenix.Form.update_options(socket.assigns.form, fn options ->
        Keyword.put(options, :selected_categories, selected_categories)
      end)

    {:noreply, assign(socket, selected_categories: selected_categories, form: form)}
  end

  @impl true
  def handle_event("save", %{"post" => params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :post_picture, fn %{key: key}, _entry ->
        {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{key}"}
      end)

    post_params =
      params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("categories", Enum.map(socket.assigns.selected_categories, &%{"name" => &1}))
      |> Map.put("pictures", Enum.map(uploaded_files, &%{"url" => &1}))

    case AshPhoenix.Form.submit(socket.assigns.form, params: post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        socket =
          socket
          |> put_flash(
            :info,
            "Post #{if socket.assigns.post, do: "updated", else: "created"} successfully"
          )
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{post: post}} = socket) do
    form =
      if post do
        AshPhoenix.Form.for_update(post, :update,
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

    {:ok, presigned_url} =
      Conga.S3Upload.presigned_put(config,
        key: key,
        content_type: entry.client_type,
        max_file_size: socket.assigns.uploads[entry.upload_config].max_file_size
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: presigned_url
    }

    {:ok, meta, socket}
  end

  defp get_selected_categories(nil), do: []
  defp get_selected_categories(%{categories: %Ash.NotLoaded{}}), do: []

  defp get_selected_categories(post) do
    post.categories
    |> Enum.map(& &1.name)
  end
end
