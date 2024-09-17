defmodule CongaWeb.PostLive.Show do
  use CongaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Post <%= @post.title %>
      <:subtitle>This is a post record from your database.</:subtitle>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/posts/#{@post}/show/edit"} phx-click={JS.push_focus()}>
            <.icon name="hero-pencil" class="text-blue-500" />
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @post.id %></:item>

      <:item title="Title"><%= @post.title %></:item>

      <:item title="Body"><%= @post.body %></:item>

      <:item title="Category"><%= @post.category %></:item>

      <:item title="Reading time"><%= @post.reading_time %></:item>

      <:item title="View count"><%= @post.page_views %></:item>

      <:item title="Total likes"><%= @post.total_likes %></:item>

      <:item title="Total comments"><%= @post.total_comments %></:item>

      <:item title="Visibility"><%= @post.visibility %></:item>

      <:item title="User"><%= @post.user_id %></:item>
    </.list>

    <.header class="my-8 justify-between">
      <%= if @current_user do %>
        <%= if @post.liked_by_user do %>
          <button phx-click="dislike" phx-value-id={@post.id}>
            <.icon name="hero-heart-solid" class="text-red-500" />
          </button>
        <% else %>
          <button phx-click="like" phx-value-id={@post.id}>
            <.icon name="hero-heart" class="text-red-500" />
          </button>
        <% end %>
      <% else %>
        <.link patch={~p"/sign-in"} phx-click={JS.push_focus()}>
          <.icon name="hero-heart" class="text-red-500" />
        </.link>
      <% end %>

      <:actions>
        <.link patch={~p"/posts/#{@post}/comments/new"} phx-click={JS.push_focus()}>
          <.button>New Comment</.button>
        </.link>
      </:actions>
    </.header>
    <div class="grid grid-cols-1 gap-4">
      <%= for comment <- @post.comments do %>
        <div class="flex items-center justify-between gap-4 pb-4 border-b-gray-200 border-b-[1px]">
          <%= comment.content %>

          <%= if @current_user  do %>
            <div>
              <.link patch={~p"/posts/#{@post}/comments/#{comment}/edit"} phx-click={JS.push_focus()}>
                <.icon name="hero-pencil" class="text-blue-500" />
              </.link>
              <.link
                data-confirm="Are you sure?"
                phx-click={JS.push("delete", value: %{id: comment.id})}
              >
                <.icon name="hero-trash" class="text-red-500" />
              </.link>
            </div>
          <% else %>
            hi
          <% end %>
        </div>
      <% end %>
    </div>

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
        id={(@comment && @comment.id) || :new_comment}
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
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Conga.Posts.Post.inc_page_views!(actor: socket.assigns.current_user)
      |> Ash.load!([
        :total_likes,
        :total_comments,
        :reading_time,
        :comments,
        :likes,
        liked_by_user: %{user_id: socket.assigns.current_user && socket.assigns.current_user.id}
      ])

    IO.inspect(post, label: "post")

    socket
    |> assign(:page_title, "Show Post")
    |> assign(:post, post)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:comments])

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_comment, _params) do
    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
  end

  defp apply_action(socket, :edit_comment, %{"c_id" => id}) do
    comment =
      Conga.Posts.Comment
      |> Ash.get!(id, actor: socket.assigns.current_user)

    socket
    |> assign(:page_title, "Edit Comment")
    |> assign(:comment, comment)
  end

  @impl true
  def handle_event("like", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.like!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, true)
      |> Ash.load!([:total_likes])

    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("dislike", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.dislike!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, false)
      |> Ash.load!([:total_likes])

    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    comment = Ash.get!(Conga.Posts.Comment, id, actor: socket.assigns.current_user)
    Ash.destroy!(comment, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :comments, comment)}
  end
end
