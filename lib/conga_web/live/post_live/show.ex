defmodule CongaWeb.PostLive.Show do
  use CongaWeb, :live_view

  import SaladUI.Button
  import SaladUI.Badge
  import SaladUI.DropdownMenu
  import SaladUI.Menu
  import SaladUI.Separator
  import SaladUI.Tooltip

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row justify-center">
      <div class="lg:w-1/5 flex justify-end items-start"></div>
      <div class="lg:w-3/5">
        <.header class="max-w-3xl mx-auto">
          <div class="flex justify-between items-center w-full">
            <.link
              navigate={~p"/posts"}
              class="inline-flex items-center px-4 py-2 text-sm font-medium text-zinc-600 hover:text-zinc-900"
            >
              <.icon name="hero-arrow-left" class="mr-2 h-5 w-5" /> Back to posts
            </.link>
            <%= if @current_user == @post.user do %>
              <.link
                patch={~p"/posts/#{@post}/show/edit"}
                phx-click={JS.push_focus()}
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-zinc-600 bg-yellow-400 hover:bg-yellow-500"
              >
                <.icon name="hero-pencil" class="mr-2 h-5 w-5" /> Edit Post
              </.link>
            <% end %>
          </div>
        </.header>
        <div class="max-w-3xl mx-auto py-8">
          <div :if={Enum.any?(@post.pictures)} class="mb-8">
            <img
              src={Enum.at(@post.pictures, -1).url}
              alt={@post.title}
              class="w-full h-64 object-cover rounded-lg shadow-md"
            />
          </div>

          <h1 class="text-4xl font-extrabold text-center text-gray-900 my-14"><%= @post.title %></h1>

          <div class="flex justify-between items-end">
            <div :if={@profile && @profile.user_id == @post.user_id} class="flex">
              <img
                class="object-cover object-center w-10 h-10 rounded-full"
                src={@profile.avatar}
                alt=""
              />
              <div class="mx-4">
                <h1 class="text-sm text-gray-700 dark:text-gray-200">
                  <%= @profile.first_name %> <%= @profile.last_name %>
                </h1>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  <%= @profile.occupation %>
                </p>
              </div>
            </div>

            <div class="text-sm text-gray-700 dark:text-gray-200 flex flex-col items-end">
              <%= @post.reading_time %> min read
              <div
                phx-hook="LocalTime"
                id={"inserted_at-#{@post.inserted_at}"}
                class="hidden md:block invisible text-sm text-gray-700"
              >
                <%= DateTime.to_string(@post.inserted_at) %>
              </div>
            </div>
          </div>

          <.separator class="my-4" />

          <div class="flex justify-between mx-2">
            <div class="flex gap-4">
              <%= if @current_user do %>
                <div class="flex gap-1 items-end">
                  <%= if @post.liked_by_user do %>
                    <button phx-click="dislike" phx-value-id={@post.id}>
                      <.icon name="hero-heart-solid" class="text-red-400" />
                    </button>
                  <% else %>
                    <button phx-click="like" phx-value-id={@post.id}>
                      <.icon name="hero-heart" class="text-red-300" />
                    </button>
                  <% end %>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.like_count %>
                  </p>
                </div>
                <div class="flex gap-1 items-end">
                  <%= if @post.bookmarked_by_user do %>
                    <button phx-click="unbookmark" phx-value-id={@post.id}>
                      <.icon name="hero-bookmark-solid" class="text-blue-400" />
                    </button>
                  <% else %>
                    <button phx-click="bookmark" phx-value-id={@post.id}>
                      <.icon name="hero-bookmark" class="text-blue-500" />
                    </button>
                  <% end %>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.bookmark_count %>
                  </p>
                </div>
              <% else %>
                <div class="flex gap-1 items-end">
                  <.link phx-click={show_modal("sign-in")}>
                    <.icon name="hero-heart" class="text-red-500" />
                  </.link>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.like_count %>
                  </p>
                </div>
                <div class="flex gap-1 items-end">
                  <.link phx-click={show_modal("sign-in")}>
                    <.icon name="hero-bookmark" class="text-blue-500" />
                  </.link>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.bookmark_count %>
                  </p>
                </div>
              <% end %>
              <div
                :if={@post.page_views > 0}
                class="flex gap-1 text-sm text-gray-500 dark:text-gray-200 items-end"
              >
                <.icon name="hero-eye" class="text-yellow-500" />
                <%= @post.page_views %>
              </div>
            </div>

            <div class="flex gap-4">
              <.dropdown_menu>
                <.dropdown_menu_trigger>
                  <.tooltip>
                    <.icon name="hero-arrow-up-on-square" class="text-yellow-500 cursor-pointer" />
                    <.tooltip_content class="bg-primary text-white">
                      <p>Share</p>
                    </.tooltip_content>
                  </.tooltip>
                </.dropdown_menu_trigger>
                <.dropdown_menu_content side="top">
                  <.menu class="">
                    <.menu_label>Share</.menu_label>
                    <.menu_separator />
                    <.menu_group>
                      <.menu_item>
                        <img src="/images/x.svg" class="mr-2 h-4 w-4" />
                        <span>Twitter</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/linkedin.svg" class="mr-2 h-4 w-4" />
                        <span>LinkedIn</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/reddit.svg" class="mr-2 h-4 w-4" />
                        <span>Reddit</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/facebook.svg" class="mr-2 h-4 w-4" />
                        <span>Facebook</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/whatsapp.svg" class="mr-2 h-4 w-4" />
                        <span>Whatsapp</span>
                      </.menu_item>
                    </.menu_group>
                    <.menu_separator />
                    <.menu_group>
                      <.menu_item>
                        <.icon name="hero-link" class="mr-2 h-4 w-4" />
                        <span>Permalink</span>
                      </.menu_item>
                    </.menu_group>
                  </.menu>
                </.dropdown_menu_content>
              </.dropdown_menu>
            </div>
          </div>

          <.separator class="mt-4 mb-20" />

          <div class="prose prose-lg max-w-none mb-8">
            <%= MDEx.to_html!(@post.body,
              features: [syntax_highlight_theme: "dracula"],
              extension: [
                strikethrough: true,
                tagfilter: true,
                table: true,
                autolink: true,
                tasklist: true,
                header_ids: "post-",
                footnotes: true,
                shortcodes: true
              ],
              parse: [
                smart: true,
                relaxed_tasklist_matching: true,
                relaxed_autolinks: true
              ],
              render: [
                github_pre_lang: true,
                unsafe_: true
              ]
            )
            |> raw() %>
          </div>

          <div class="grid grid-cols-2 gap-4 mb-8">
            <div class="bg-white p-4 rounded-lg shadow">
              <h2 class="text-xl font-semibold mb-2">Post Details</h2>
              <.list>
                <:item title="Reading time"><%= @post.reading_time %> min</:item>
                <:item title="View count"><%= @post.page_views %></:item>
                <:item title="Total likes"><%= @post.like_count %></:item>
                <:item title="Total comments"><%= @post.comment_count %></:item>
              </.list>
            </div>
            <div class="bg-white p-4 rounded-lg shadow">
              <h2 class="text-xl font-semibold mb-2">Additional Info</h2>
              <.list>
                <:item title="Total bookmarks"><%= @post.bookmark_count %></:item>
                <:item title="Popularity score"><%= @post.popularity_score %></:item>
                <:item title="Visibility"><%= @post.visibility %></:item>
                <:item title="Author"><%= @profile && @profile.first_name %></:item>
              </.list>
            </div>
          </div>

          <div class="mb-8">
            <h2 class="text-xl font-semibold mb-4">Categories</h2>
            <div class="flex flex-wrap gap-2">
              <%= for category <- @post.categories_join_assoc do %>
                <%= for post_category <- @categories do %>
                  <%= if category.category_id == post_category.id do %>
                    <.link navigate={~p"/posts/category/#{category.category_id}"}>
                      <.badge
                        variant="outline"
                        class="border-yellow-400 bg-white text-yellow-500 bg-opacity-35 mb-2 justify-center"
                      >
                        <.icon name="hero-tag" class="mr-1 w-4 h-4" />
                        <%= post_category.name %>
                      </.badge>
                    </.link>
                  <% end %>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>

        <div class="max-w-3xl mx-auto">
          <.separator class="my-4" />

          <div class="flex justify-between mx-2">
            <div class="flex gap-4">
              <%= if @current_user do %>
                <div class="flex gap-1 items-end">
                  <%= if @post.liked_by_user do %>
                    <button phx-click="dislike" phx-value-id={@post.id}>
                      <.icon name="hero-heart-solid" class="text-red-400" />
                    </button>
                  <% else %>
                    <button phx-click="like" phx-value-id={@post.id}>
                      <.icon name="hero-heart" class="text-red-300" />
                    </button>
                  <% end %>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.like_count %>
                  </p>
                </div>
                <div class="flex gap-1 items-end">
                  <%= if @post.bookmarked_by_user do %>
                    <button phx-click="unbookmark" phx-value-id={@post.id}>
                      <.icon name="hero-bookmark-solid" class="text-blue-400" />
                    </button>
                  <% else %>
                    <button phx-click="bookmark" phx-value-id={@post.id}>
                      <.icon name="hero-bookmark" class="text-blue-500" />
                    </button>
                  <% end %>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.bookmark_count %>
                  </p>
                </div>
              <% else %>
                <div class="flex gap-1 items-end">
                  <.link phx-click={show_modal("sign-in")}>
                    <.icon name="hero-heart" class="text-red-500" />
                  </.link>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.like_count %>
                  </p>
                </div>
                <div class="flex gap-1 items-end">
                  <.link phx-click={show_modal("sign-in")}>
                    <.icon name="hero-bookmark" class="text-blue-500" />
                  </.link>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    <%= @post.bookmark_count %>
                  </p>
                </div>
              <% end %>
              <div
                :if={@post.page_views > 0}
                class="flex gap-1 text-sm text-gray-500 dark:text-gray-200 items-end"
              >
                <.icon name="hero-eye" class="text-yellow-500" />
                <%= @post.page_views %>
              </div>
            </div>

            <div class="flex gap-4">
              <.dropdown_menu>
                <.dropdown_menu_trigger>
                  <.tooltip>
                    <.icon name="hero-arrow-up-on-square" class="text-yellow-500 cursor-pointer" />
                    <.tooltip_content class="bg-primary text-white">
                      <p>Share</p>
                    </.tooltip_content>
                  </.tooltip>
                </.dropdown_menu_trigger>
                <.dropdown_menu_content side="top">
                  <.menu class="">
                    <.menu_label>Share</.menu_label>
                    <.menu_separator />
                    <.menu_group>
                      <.menu_item>
                        <img src="/images/x.svg" class="mr-2 h-4 w-4" />
                        <span>Twitter</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/linkedin.svg" class="mr-2 h-4 w-4" />
                        <span>LinkedIn</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/reddit.svg" class="mr-2 h-4 w-4" />
                        <span>Reddit</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/facebook.svg" class="mr-2 h-4 w-4" />
                        <span>Facebook</span>
                      </.menu_item>
                      <.menu_item>
                        <img src="/images/whatsapp.svg" class="mr-2 h-4 w-4" />
                        <span>Whatsapp</span>
                      </.menu_item>
                    </.menu_group>
                    <.menu_separator />
                    <.menu_group>
                      <.menu_item>
                        <.icon name="hero-link" class="mr-2 h-4 w-4" />
                        <span>Permalink</span>
                      </.menu_item>
                    </.menu_group>
                  </.menu>
                </.dropdown_menu_content>
              </.dropdown_menu>
            </div>
          </div>

          <.separator class="mt-4 mb-20" />
        </div>

        <div class="flex my-8 justify-between max-w-3xl mx-auto items-end">
          <div class="">
            <%= @post.comment_count %> Comments
          </div>

          <%= if @current_user do %>
            <.link patch={~p"/posts/#{@post}/comments/new"} phx-click={JS.push_focus()}>
              <.button>New Comment</.button>
            </.link>
          <% else %>
            <.button phx-click={show_modal("sign-in")}>New Comment</.button>
          <% end %>
        </div>

        <.comment_tree
          stream={@streams.comments}
          current_user={@current_user}
          post={@post}
          profile={@profile}
        />

        <div class="max-w-3xl mx-auto px-4 py-8">
          <.back navigate={~p"/posts"}>Back to posts</.back>
        </div>
      </div>
      <div class="lg:w-1/5 hidden lg:block">
        <div class="sticky top-60">
          <h2 class="text-2xl font-bold mb-4">Table of Contents</h2>
          <ul class="toc-list" id="toc-list" phx-hook="TableOfContents">
            <!-- TOC items will be dynamically inserted here -->
          </ul>
        </div>
      </div>
    </div>

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
    profiles = Conga.Accounts.Profile.read!(actor: socket.assigns.current_user)

    {:ok,
     socket
     |> assign(:profiles, profiles)}
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

    user =
      post.user
      |> Ash.load!([:profile])

    # IO.inspect(user, label: "user")

    socket
    |> assign(:page_title, "Show Post")
    |> assign(:post, post)
    |> assign(:comments, comments)
    |> stream(:comments, comments, reset: true)
    |> assign(:categories, categories)
    |> assign(:profile, user.profile)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_user = socket.assigns.current_user

    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: current_user)
      |> Ash.load!(post_fields(socket))

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
      |> Ash.load!(post_fields(socket))

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
      |> Ash.load!(post_fields(socket))

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
      |> Ash.load!(post_fields(socket))

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
      :categories,
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
    <.comment id={@id} comment={@comment} current_user={@current_user} post={@post} profile={@profile}>
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
    <div
      id={@id}
      class="border-l-2 border-gray-200 pl-2 sm:pl-4 flex flex-col sm:flex-row items-start sm:space-y-0 sm:space-x-4 mt-4 max-w-3xl mx-auto"
    >
      <img
        :if={@comment.user_id == @profile.user_id}
        class="object-cover object-center w-10 h-10 sm:w-12 sm:h-12 rounded-full"
        src={@profile.avatar}
        alt=""
      />
      <div class="flex-grow w-full sm:w-auto">
        <div class="flex sm:flex-row sm:items-center items-center justify-between mb-2">
          <span :if={@comment.user_id == @profile.user_id} class="font-semibold text-sm sm:text-base">
            <%= @profile.first_name %>
          </span>
          <div :if={@current_user} class="flex items-center space-x-2 mt-2 sm:mt-0">
            <.link patch={~p"/posts/#{@post}/comments/#{@comment}/new"} phx-click={JS.push_focus()}>
              <Lucideicons.reply class="text-blue-400 w-4 h-4 sm:w-5 sm:h-5" />
            </.link>
            <.dropdown_menu :if={@current_user && @current_user.id == @comment.user_id}>
              <.dropdown_menu_trigger>
                <.button aria-haspopup="true" size="icon" variant="ghost" class="p-1 sm:p-2">
                  <Lucideicons.ellipsis class="h-4 w-4" />
                  <span class="sr-only">Toggle menu</span>
                </.button>
              </.dropdown_menu_trigger>
              <.dropdown_menu_content align="end">
                <.menu>
                  <.menu_label>Actions</.menu_label>
                  <.menu_item>
                    <.link
                      patch={~p"/posts/#{@post}/comments/#{@comment}/edit"}
                      phx-click={JS.push_focus()}
                      class="flex items-center space-x-2"
                    >
                      <.icon name="hero-pencil-square" class="text-blue-400 w-4 h-4 sm:w-5 sm:h-5" />
                      <span class="text-sm sm:text-base">Edit</span>
                    </.link>
                  </.menu_item>
                  <.menu_item>
                    <.link
                      data-confirm="Are you sure?"
                      phx-click={JS.push("delete", value: %{id: @comment.id})}
                      class="flex items-center space-x-2"
                    >
                      <.icon name="hero-trash" class="text-red-400 w-4 h-4 sm:w-5 sm:h-5" />
                      <span class="text-sm sm:text-base">Delete</span>
                    </.link>
                  </.menu_item>
                </.menu>
              </.dropdown_menu_content>
            </.dropdown_menu>
          </div>
        </div>
        <p class="text-xs sm:text-sm text-gray-700"><%= @comment.content %></p>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
