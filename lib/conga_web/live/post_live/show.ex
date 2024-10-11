defmodule CongaWeb.PostLive.Show do
  use CongaWeb, :live_view

  import SaladUI.Button
  import SaladUI.DropdownMenu
  import SaladUI.Menu

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

      <:item title="Reading time"><%= @post.reading_time %></:item>

      <:item title="View count"><%= @post.page_views %></:item>

      <:item title="Total likes"><%= @post.like_count %></:item>

      <:item title="Total comments"><%= @post.comment_count %></:item>

      <:item title="Total bookmarks"><%= @post.bookmark_count %></:item>

      <:item title="Popularity score"><%= @post.popularity_score %></:item>

      <:item title="Visibility"><%= @post.visibility %></:item>

      <:item title="User"><%= @post.user_id %></:item>
    </.list>

    <div class="mt-4 flex flex-row gap-4">
      <div :for={category <- @post.categories_join_assoc} class="flex">
        <div
          :for={post_category <- @categories}
          :if={category.category_id == post_category.id}
          class="text-blue-400"
        >
          <.link
            navigate={~p"/posts/category/#{category.category_id}"}
            class="flexw gap-2 items-center"
          >
            <.icon name="hero-tag" class="text-blue-400 w-4 h-4" />

            <%= post_category.name %>
          </.link>
        </div>
      </div>
    </div>

    <div class="flex my-8 justify-between">
      <div class="flex gap-4">
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
          <.link phx-click={show_modal("sign-in")}>
            <.icon name="hero-heart" class="text-red-500" />
          </.link>
          <.link phx-click={show_modal("sign-in")}>
            <.icon name="hero-bookmark" class="text-blue-500" />
          </.link>
        <% end %>
      </div>

      <%= if @current_user do %>
        <.link patch={~p"/posts/#{@post}/comments/new"} phx-click={JS.push_focus()}>
          <.button>New Comment</.button>
        </.link>
      <% else %>
        <.button phx-click={show_modal("sign-in")}>New Comment</.button>
      <% end %>
    </div>

    <.comment_tree stream={@streams.comments} current_user={@current_user} post={@post} />

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

    <.sign_modal id="sign-in" on_cancel={hide_modal("sign-in")}>
      <div class="flex flex-col gap-10">
        <img src={~p"/images/logo.jpg"} class="w-32 h-32 mx-auto rounded-full" />
        <h2 class="text-xl font-semibold text-gray-800 dark:text-white text-center">
          Hey, 👋 sign up or sign in to interact.
        </h2>
        <.link patch={~p"/sign-in"}>
          <.button class="w-full">
            <.icon name="hero-user-circle" class="w-5 h-5 mr-2" /> Sign in with Conga
          </.button>
        </.link>
      </div>
    </.sign_modal>
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
      |> Ash.load!(post_fields(socket))

    # IO.inspect(post, label: "post")

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
        |> Ash.load!([:child_comments, :user, :parent_comment])
      end)

    # IO.inspect(comments, label: "comments")

    current_user = socket.assigns.current_user

    categories = Conga.Posts.Category.list_all!(actor: current_user)

    socket
    |> assign(:page_title, "Show Post")
    |> assign(:post, post)
    |> assign(:comments, comments)
    |> stream(:comments, comments, reset: true)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_user = socket.assigns.current_user

    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: current_user)
      |> Ash.load!([:comments, :categories_join_assoc])

    categories = Conga.Posts.Category.list_all!(actor: current_user)

    socket
    |> assign(:page_title, "Edit Post")
    |> stream(:comments, post.comments)
    |> assign(:post, post)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :new_comment, %{"id" => post_id}) do
    current_user = socket.assigns.current_user

    post =
      Conga.Posts.Post
      |> Ash.get!(post_id, actor: current_user)
      |> Ash.load!([:comments, :categories_join_assoc])

    categories = Conga.Posts.Category.list_all!(actor: current_user)

    comments = post.comments

    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
    |> assign(:parent_comment, nil)
    |> assign(:post, post)
    |> stream(:comments, comments)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :new_comment_child, %{"c_id" => id}) do
    current_user = socket.assigns.current_user

    parent_comment =
      Conga.Posts.Comment
      |> Ash.get!(id, actor: current_user)
      |> Ash.load!([:post, :child_comments, :parent_comment])

    categories = Conga.Posts.Category.list_all!(actor: current_user)

    post =
      parent_comment.post
      |> Ash.load!([:comments, :categories_join_assoc])

    comments = post.comments

    socket
    |> assign(:page_title, "New Comment")
    |> assign(:comment, nil)
    |> stream(:comments, comments)
    |> assign(:parent_comment, parent_comment)
    |> assign(:post, post)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :edit_comment, %{"c_id" => id}) do
    comment =
      Conga.Posts.Comment
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Ash.load!([:post, :parent_comment])

    post =
      comment.post
      |> Ash.load!([:comments, :categories_join_assoc])

    socket
    |> assign(:page_title, "Edit Comment")
    |> stream(:comments, post.comments)
    |> assign(:comment, comment)
    |> assign(:parent_comment, nil)
    |> assign(:post, post)
  end

  @impl true
  def handle_info({CongaWeb.CommentLive.FormComponent, {:saved, comment}}, socket) do
    categories = Conga.Posts.Category.list_all!(actor: socket.assigns.current_user)

    comment =
      comment |> Ash.load!([:user, :post, :child_comments, :parent_comment])

    post = comment.post |> Ash.load!([:comments])

    {:noreply,
     socket
     |> stream_insert(:comments, comment)
     |> assign(comments: post.comments)
     |> assign(:categories, categories)}
  end

  @impl true
  def handle_info({CongaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    categories = Conga.Posts.Category.list_all!(actor: socket.assigns.current_user)

    post =
      post
      |> Ash.load!(post_fields(socket))

    comments = post.comments

    {:noreply,
     socket
     |> stream(:comments, comments)
     |> assign(:categories, categories)
     |> assign(:post, post)}
  end

  @impl true
  def handle_event("like", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.like!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, true)
      |> Ash.load!([:like_count, :comments, :popularity_score, :comment_count])

    comments = post.comments

    {:noreply,
     socket
     |> assign(:post, post)
     |> stream(:comments, comments)}
  end

  def handle_event("dislike", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.dislike!(actor: socket.assigns.current_user)
      |> Map.put(:liked_by_user, false)
      |> Ash.load!([:like_count, :comments, :popularity_score, :comment_count])

    comments = post.comments

    {:noreply,
     socket
     |> assign(:post, post)
     |> stream(:comments, comments)}
  end

  @impl true
  def handle_event("bookmark", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.bookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, true)
      |> Ash.load!([:bookmark_count, :comments, :popularity_score])

    comments = post.comments

    {:noreply,
     socket
     |> assign(:post, post)
     |> stream(:comments, comments)}
  end

  def handle_event("unbookmark", _params, socket) do
    post =
      socket.assigns.post
      |> Conga.Posts.Post.unbookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, false)
      |> Ash.load!([:bookmark_count, :comments, :popularity_score])

    comments = post.comments

    {:noreply,
     socket
     |> assign(:post, post)
     |> stream(:comments, comments)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    comment =
      Ash.get!(Conga.Posts.Comment, id, actor: socket.assigns.current_user)
      |> Ash.load!([:post])

    Ash.destroy!(comment, actor: socket.assigns.current_user)

    post = comment.post |> Ash.load!([:comments])

    {:noreply,
     socket
     |> stream_delete(:comments, comment)
     |> assign(:comments, post.comments)
     |> put_flash(:info, "Comment deleted successfully.")}
  end

  def post_fields(socket) do
    [
      :like_count,
      :comment_count,
      :bookmark_count,
      :reading_time,
      :popularity_score,
      :comments,
      :pictures,
      :bookmarks,
      :categories_join_assoc,
      :likes,
      :user,
      liked_by_user: %{user_id: socket.assigns.current_user && socket.assigns.current_user.id},
      bookmarked_by_user: %{
        user_id: socket.assigns.current_user && socket.assigns.current_user.id
      }
    ]
  end

  defp comment_tree(assigns) do
    ~H"""
    <div class="space-y-4" phx-update="stream" id="comments">
      <%= for {id, comment} <- @stream do %>
        <%= if is_nil(comment.parent_comment_id) do %>
          <%= render_comment(assigns, id, comment) %>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp render_comment(assigns, id, comment) do
    assigns = assign(assigns, :comment, comment)
    assigns = assign(assigns, :id, id)

    ~H"""
    <.comment id={@id} comment={@comment} current_user={@current_user} post={@post}>
      <div phx-update="stream" id="comments">
        <%= for {child_id, child_comment} <- @stream do %>
          <%= if child_comment.parent_comment_id == @comment.id do %>
            <%= render_comment(assigns, child_id, child_comment) %>
          <% end %>
        <% end %>
      </div>
    </.comment>
    """
  end

  defp comment(assigns) do
    ~H"""
    <div id={@id} class="border-l-2 border-gray-200 pl-4">
      <div class="flex items-center gap-2">
        <Lucideicons.user class="h-5 w-5" /> <span><%= Faker.Person.first_name() %></span>
      </div>
      <div class="flex items-center justify-between gap-4 mb-8 text-sm text-gray-700">
        <%= @comment.content %>
        <div :if={@current_user} class="flex gap-2 items-center">
          <.link patch={~p"/posts/#{@post}/comments/#{@comment}/new"} phx-click={JS.push_focus()}>
            <Lucideicons.reply class="text-blue-400 w-5 h-5" />
          </.link>
          <.dropdown_menu
            :if={@current_user && @current_user.id == @comment.user_id}
            class="flex gap-2"
          >
            <.dropdown_menu_trigger>
              <.button aria-haspopup="true" size="icon" variant="ghost">
                <Lucideicons.ellipsis class="h-4 w-4" />
                <span class="sr-only">Toggle menu</span>
              </.button>
            </.dropdown_menu_trigger>
            <.dropdown_menu_content align="end">
              <.menu>
                <.menu_label>Actions</.menu_label>
                <.menu_item class="justify-center">
                  <.link
                    patch={~p"/posts/#{@post}/comments/#{@comment}/edit"}
                    phx-click={JS.push_focus()}
                  >
                    <.icon name="hero-pencil-square" class="text-blue-400 w-5 h-5" />
                  </.link>
                </.menu_item>
                <.menu_item class="justify-center">
                  <.link
                    data-confirm="Are you sure?"
                    phx-click={JS.push("delete", value: %{id: @comment.id})}
                  >
                    <.icon name="hero-trash" class="text-red-400 w-5 h-5" />
                  </.link>
                </.menu_item>
              </.menu>
            </.dropdown_menu_content>
          </.dropdown_menu>
        </div>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
