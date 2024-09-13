defmodule CongaWeb.PostLive.Show do
  use CongaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Post <%= @post.id %>
      <:subtitle>This is a post record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/posts/#{@post}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit post</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @post.id %></:item>

      <:item title="Title"><%= @post.title %></:item>

      <:item title="Body"><%= @post.body %></:item>

      <:item title="Category"><%= @post.category %></:item>

      <:item title="Reading time"><%= @post.reading_time %></:item>

      <:item title="Total likes"><%= @post.total_likes %></:item>

      <:item title="Visibility"><%= @post.visibility %></:item>

      <:item title="User"><%= @post.user_id %></:item>
    </.list>

    <.header class="mt-8">
      Listing Comments
      <:actions>
        <.link patch={~p"/posts/#{@post}/comments/new"} phx-click={JS.push_focus()}>
          <.button>New Comment</.button>
        </.link>
      </:actions>
    </.header>

    <ul>
      <%= for comment <- @post.comments do %>
        <li>
          <%= comment.body %>
        </li>
      <% end %>
    </ul>

    <.back navigate={~p"/posts"}>Back to posts</.back>

    <.modal :if={@live_action == :edit} id="post-modal" show on_cancel={JS.patch(~p"/posts/#{@post}")}>
      <.live_component
        module={CongaWeb.PostLive.FormComponent}
        id={@post.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        post={@post}
        patch={~p"/posts/#{@post}"}
      />
    </.modal>

    <.modal
      :if={@live_action in [:new_comment, :edit_comment]}
      id="comment-modal"
      show
      on_cancel={JS.patch(~p"/posts/#{@post}")}
    >
      <.live_component
        module={CongaWeb.CommentLive.FormComponent}
        id={(@comment && @comment.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        post={@post}
        comment={@comment}
        patch={~p"/posts/#{@post}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:comments, Ash.read!(Conga.Posts.Comment, actor: socket.assigns[:current_user]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:total_likes, :reading_time, :comments])

    socket
    |> assign(:page_title, "Show Post")
    |> assign(:post, post)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:total_likes, :reading_time, :comments])

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_comment, _params) do
    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
  end

  defp apply_action(socket, :edit_comment, %{"id" => id}) do
    comment =
      Conga.Posts.Comment
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:post])

    socket
    |> assign(:page_title, "Edit Comment")
    |> assign(:comment, comment)
  end
end
