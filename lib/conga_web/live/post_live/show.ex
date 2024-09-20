defmodule CongaWeb.PostLive.Show do
  use CongaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Post <%= @post.title %>
      <:subtitle>This is a post record from your database.</:subtitle>

      <:actions>
        <%= if @current_user == @post.user do %>
          <.link patch={~p"/posts/#{@post}/show/edit"} phx-click={JS.push_focus()}>
            <.icon name="hero-pencil" class="text-blue-400" />
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

      <:item title="Total bookmarks"><%= @post.total_bookmarks %></:item>

      <:item title="Popularity score"><%= @post.popularity_score %></:item>

      <:item title="Visibility"><%= @post.visibility %></:item>

      <:item title="User"><%= @post.user_id %></:item>
    </.list>

    <.header class="my-8 justify-between">
      <%= if @current_user do %>
        <%= if @post.liked_by_user do %>
          <button phx-click="dislike" phx-value-id={@post.id}>
            <.icon name="hero-heart-solid" class="text-red-400" />
          </button>
        <% else %>
          <button phx-click="like" phx-value-id={@post.id}>
            <.icon name="hero-heart" class="text-red-300" />
          </button>
        <% end %>
        <%= if @post.bookmarked_by_user do %>
          <button phx-click="unbookmark" phx-value-id={@post.id}>
            <.icon name="hero-bookmark-solid" class="text-blue-400" />
          </button>
        <% else %>
          <button phx-click="bookmark" phx-value-id={@post.id}>
            <.icon name="hero-bookmark" class="text-blue-500" />
          </button>
        <% end %>
      <% else %>
        <.link patch={~p"/sign-in"} phx-click={JS.push_focus()}>
          <.icon name="hero-heart" class="text-red-500" />
        </.link>
        <.link patch={~p"/sign-in"} phx-click={JS.push_focus()}>
          <.icon name="hero-bookmark" class="text-blue-500" />
        </.link>
      <% end %>

      <:actions>
        <.link patch={~p"/posts/#{@post}/comments/new"} phx-click={JS.push_focus()}>
          <.button>New Comment</.button>
        </.link>
      </:actions>
    </.header>

    <.comment_tree comments={@post.comments} current_user={@current_user} post={@post} />

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
      :if={@live_action in [:new_comment, :edit_comment, :new_comment_child]}
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
        parent_comment={@parent_comment}
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
      |> Ash.load!([
        :total_likes,
        :total_comments,
        :total_bookmarks,
        :reading_time,
        :popularity_score,
        :comments,
        :bookmarks,
        :likes,
        :user,
        liked_by_user: %{user_id: socket.assigns.current_user && socket.assigns.current_user.id},
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    IO.inspect(post, label: "post")

    # Only increment page views if it's not a reconnection
    unless connected?(socket) do
      Conga.Posts.Post.inc_page_views!(post,
        actor: socket.assigns.current_user,
        authorize?: false
      )
    end

    comments =
      post.comments
      |> Enum.map(fn comment ->
        comment
        |> Ash.load!([:child_comments, :user])
      end)

    IO.inspect(comments, label: "comments")

    socket
    |> assign(:page_title, "Show Post")
    |> assign(:post, post)
    |> assign(:comments, comments)
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

  defp apply_action(socket, :new_comment, %{"id" => post_id}) do
    post =
      Conga.Posts.Post
      |> Ash.get!(post_id, actor: socket.assigns.current_user)
      |> Ash.load!([:comments])

    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
    |> assign(:parent_comment, nil)
    |> assign(:post, post)
  end

  defp apply_action(socket, :new_comment_child, %{"c_id" => id}) do
    parent_comment =
      Conga.Posts.Comment
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:post, :child_comments, :parent_comment])

    post =
      parent_comment.post
      |> Ash.load!([:comments])

    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
    |> assign(:parent_comment, parent_comment)
    |> assign(:post, post)
  end

  defp apply_action(socket, :edit_comment, %{"c_id" => id}) do
    comment =
      Conga.Posts.Comment
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!(:post)

    post =
      comment.post
      |> Ash.load!(:comments)

    socket
    |> assign(:page_title, "Edit Comment")
    |> assign(:comment, comment)
    |> assign(:parent_comment, nil)
    |> assign(:post, post)
  end

  @impl true
  def handle_event("like", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.like!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, true)
      |> Ash.load!([:total_likes, :popularity_score])

    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("dislike", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.dislike!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, false)
      |> Ash.load!([:total_likes, :popularity_score])

    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_event("bookmark", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.bookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, true)
      |> Ash.load!([:total_bookmarks, :popularity_score])

    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("unbookmark", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.unbookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, false)
      |> Ash.load!([:total_bookmarks, :popularity_score])

    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    comment = Ash.get!(Conga.Posts.Comment, id, actor: socket.assigns.current_user)
    Ash.destroy!(comment, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :comments, comment)}
  end

  defp comment_tree(assigns) do
    ~H"""
    <div class="space-y-4">
      <%= for comment <- root_comments(assigns.comments) do %>
        <%= render_comment(assigns, comment) %>
      <% end %>
    </div>
    """
  end

  defp render_comment(assigns, comment) do
    assigns = assign(assigns, :comment, comment)

    ~H"""
    <.comment comment={@comment} current_user={@current_user} post={@post}>
      <%= if has_child_comments?(@comments, @comment.id) do %>
        <%= for child_comment <- get_child_comments(@comments, @comment.id) do %>
          <%= render_comment(assigns, child_comment) %>
        <% end %>
      <% end %>
    </.comment>
    """
  end

  defp comment(assigns) do
    ~H"""
    <div class="border-l-2 border-gray-200 pl-4">
      <div class="flex items-center justify-between gap-4 pb-2 text-sm text-gray-700">
        <%= @comment.content %>
        <div :if={@current_user} class="flex gap-2">
          <.link patch={~p"/posts/#{@post}/comments/#{@comment}/new"} phx-click={JS.push_focus()}>
            <.icon name="hero-chat-bubble-left-ellipsis" class="text-blue-400 w-5 h-5" />
          </.link>
          <div :if={@current_user.id == @comment.user_id}>
            <.link patch={~p"/posts/#{@post}/comments/#{@comment}/edit"} phx-click={JS.push_focus()}>
              <.icon name="hero-pencil" class="text-blue-400 w-5 h-5" />
            </.link>
            <.link
              data-confirm="Are you sure?"
              phx-click={JS.push("delete", value: %{id: @comment.id})}
            >
              <.icon name="hero-trash" class="text-red-400 w-5 h-5" />
            </.link>
          </div>
        </div>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp root_comments(comments) do
    Enum.filter(comments, &is_nil(&1.parent_comment_id))
  end

  defp get_child_comments(comments, parent_id) do
    Enum.filter(comments, &(&1.parent_comment_id == parent_id))
  end

  defp has_child_comments?(comments, parent_id) do
    !Enum.empty?(get_child_comments(comments, parent_id))
  end
end
