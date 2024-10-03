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
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, post_params))}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    post_params =
      Map.put(post_params, "user_id", socket.assigns.current_user.id)
      |> Map.put("categories", [
        %{"name" => "Book"},
        %{"name" => "Blog"}
      ])

    # |> Map.put("add_category", %{"name" => "Blog"})

    IO.inspect(post_params, label: "post_params")

    case AshPhoenix.Form.submit(socket.assigns.form, params: post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        socket =
          socket
          |> put_flash(:info, "Post #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
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
      else
        AshPhoenix.Form.for_create(Conga.Posts.Post, :create,
          as: "post",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
