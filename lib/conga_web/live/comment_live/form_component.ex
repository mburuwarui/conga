defmodule CongaWeb.CommentLive.FormComponent do
  use CongaWeb, :live_component
  import SaladUI.Button
  import SaladUI.Input
  import SaladUI.Table

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage comment records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="comment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:content]} label="Content" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Comment</.button>
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
  def handle_event("validate", %{"comment" => comment_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, comment_params))}
  end

  def handle_event("save", %{"comment" => comment_params}, socket) do
    comment_params =
      case socket.assigns.parent_comment do
        nil ->
          Map.put(comment_params, "user_id", socket.assigns.current_user.id)
          |> Map.put("post_id", socket.assigns.post.id)

        parent_comment ->
          Map.put(comment_params, "user_id", socket.assigns.current_user.id)
          |> Map.put("post_id", socket.assigns.post.id)
          |> Map.put("parent_comment_id", parent_comment.id)
      end

    case AshPhoenix.Form.submit(socket.assigns.form, params: comment_params) do
      {:ok, comment} ->
        notify_parent({:saved, comment})

        socket =
          socket
          |> put_flash(:info, "Comment #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{comment: comment}} = socket) do
    form =
      if comment do
        AshPhoenix.Form.for_update(comment, :update,
          as: "comment",
          actor: socket.assigns.current_user
        )
      else
        if socket.assigns.parent_comment do
          AshPhoenix.Form.for_create(Conga.Posts.Comment, :create_child_comment,
            as: "comment",
            actor: socket.assigns.current_user
          )
        else
          AshPhoenix.Form.for_create(Conga.Posts.Comment, :create,
            as: "comment",
            actor: socket.assigns.current_user
          )
        end
      end

    assign(socket, form: to_form(form))
  end
end
