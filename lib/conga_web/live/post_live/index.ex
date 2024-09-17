defmodule CongaWeb.PostLive.Index do
  use CongaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Posts
      <:actions>
        <.link :if={@current_user} patch={~p"/posts/new"}>
          <.button>New Post</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="posts"
      rows={@streams.posts}
      row_click={fn {_id, post} -> JS.navigate(~p"/posts/#{post}") end}
    >
      <:col :let={{_id, post}} label="Id"><%= post.id %></:col>

      <:col :let={{_id, post}} label="Title"><%= post.title %></:col>

      <:col :let={{_id, post}} label="Body"><%= post.body %></:col>

      <:col :let={{_id, post}} label="Category"><%= post.category %></:col>

      <:col :let={{_id, post}} label="Reading time"><%= post.reading_time %></:col>

      <:col :let={{_id, post}} label="Visibility"><%= post.visibility %></:col>

      <:col :let={{_id, post}} label="User"><%= post.user_id %></:col>

      <:action :let={{_id, post}}>
        <div class="sr-only">
          <.link navigate={~p"/posts/#{post}"}>Show</.link>
        </div>

        <.link :if={@current_user} patch={~p"/posts/#{post}/edit"}>
          <.icon name="hero-pencil" class="text-blue-500" />
        </.link>
      </:action>

      <:action :let={{id, post}}>
        <.link
          :if={@current_user}
          phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash" class="text-red-500" />
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="post-modal" show on_cancel={JS.patch(~p"/posts")}>
      <.live_component
        module={CongaWeb.PostLive.FormComponent}
        id={(@post && @post.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        post={@post}
        patch={~p"/posts"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    posts =
      Conga.Posts.Post
      |> Ash.read!(actor: current_user)
      |> Ash.load!([:total_likes, :reading_time, :likes, :comments, :bookmarks])

    {:ok,
     socket
     |> stream(:posts, posts)
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Ash.get!(Conga.Posts.Post, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({CongaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post =
      Ash.get!(Conga.Posts.Post, id, actor: socket.assigns.current_user)

    Ash.destroy!(post, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end
