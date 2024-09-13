defmodule CongaWeb.CommentLive.Show do
  use CongaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Comment <%= @comment.id %>
      <:subtitle>This is a comment record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/posts/#{@post}/comments/#{@comment}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit comment</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @comment.id %></:item>

      <:item title="Content"><%= @comment.content %></:item>

      <:item title="Is approved"><%= @comment.is_approved %></:item>

      <:item title="Post"><%= @comment.post_id %></:item>

      <:item title="User"><%= @comment.user_id %></:item>
    </.list>

    <.back navigate={~p"/posts/#{@post}"}>Back to comments</.back>

    <.modal
      :if={@live_action == :edit}
      id="comment-modal"
      show
      on_cancel={JS.patch(~p"/posts/#{@post}")}
    >
      <.live_component
        module={CongaWeb.CommentLive.FormComponent}
        id={@comment.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        comment={@comment}
        patch={~p"/posts/#{@post}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:comments])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:comment, post.comments |> Enum.find(&(&1.id == id)))}
  end

  defp page_title(:show), do: "Show Comment"
  defp page_title(:edit), do: "Edit Comment"
end
