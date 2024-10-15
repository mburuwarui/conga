defmodule CongaWeb.PostLive.Index do
  use CongaWeb, :blog_view
  import SaladUI.Button
  import SaladUI.DropdownMenu
  import SaladUI.Menu
  import SaladUI.Badge

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <div class="w-full text-center mb-4 sm:mb-10">
        <h1 class="text-4xl font-extrabold">Listing Posts</h1>
      </div>

      <div class="py-4 flex sm:flex-row flex-col justify-between gap-4 items-center">
        <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4">
          <div class="flex flex-wrap gap-2 w-full sm:w-auto">
            <.link
              :for={category <- @categories}
              patch={~p"/posts/category/#{category.id}"}
              class="w-full sm:w-auto"
            >
              <button class={[
                "w-full sm:w-auto px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
                @current_category == category.id && "bg-indigo-600 text-white",
                @current_category != category.id && "text-gray-700 bg-gray-200 hover:bg-gray-300"
              ]}>
                <%= category.name %>
              </button>
            </.link>
            <.link patch={~p"/posts"} class="w-full sm:w-auto">
              <button class={[
                "w-full sm:w-auto px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
                @current_category == nil && "bg-indigo-600 text-white",
                @current_category != nil && "text-gray-700 bg-gray-200 hover:bg-gray-300"
              ]}>
                All Categories
              </button>
            </.link>
          </div>

          <.dropdown_menu class="w-full sm:w-auto">
            <.dropdown_menu_trigger>
              <.button
                aria-haspopup="true"
                variant="outline"
                class="w-full sm:w-auto items-center gap-2"
              >
                <.icon name="hero-bars-3-bottom-left" class="h-6 w-6" />
                <span>Sort by</span>
              </.button>
            </.dropdown_menu_trigger>
            <.dropdown_menu_content align="start">
              <.menu>
                <.menu_item class="justify-center">
                  <.link phx-click="sort_by_latest">
                    Latest
                  </.link>
                </.menu_item>
                <.menu_item class="justify-center">
                  <.link phx-click="sort_by_popularity">
                    Popular
                  </.link>
                </.menu_item>
              </.menu>
            </.dropdown_menu_content>
          </.dropdown_menu>
        </div>
        <div class="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
          <.link :if={@current_user} patch={~p"/posts/new"} class="w-full sm:w-auto">
            <.button class="w-full sm:w-auto">New Post</.button>
          </.link>
          <.link patch={~p"/search"} class="w-full sm:w-auto">
            <.button class="w-full sm:w-auto text-gray-500 bg-white hover:ring-gray-500 hover:text-white ring-gray-300 items-center gap-10 rounded-md px-3 text-sm ring-1 transition focus:[&:not(:focus-visible)]:outline-none">
              <div class="flex items-center gap-2">
                <Lucideicons.search class="h-4 w-4" />
                <span class="flex-grow text-left">Find posts</span>
              </div>
              <kbd class="hidden sm:inline-flex text-3xs opacity-80">
                <kbd class="font-sans">⌘</kbd><kbd class="font-sans">K</kbd>
              </kbd>
            </.button>
          </.link>
        </div>
      </div>
    </.header>
    <div
      class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4"
      phx-update="stream"
      id="posts"
    >
      <div :for={{id, post} <- @streams.posts} class="card flex flex-col h-full group" id={id}>
        <div class="relative flex-shrink-0 overflow-hidden rounded-lg">
          <.link :if={Enum.any?(post.pictures)} navigate={~p"/posts/#{post}"}>
            <img
              class="object-cover object-center w-full h-64 rounded-lg lg:h-80 transition-all duration-300 ease-in-out group-hover:scale-110 group-hover:shadow-xl"
              src={Enum.at(post.pictures, -1).url}
              alt=""
            />
            <div class="absolute inset-0 bg-black bg-opacity-0 transition-opacity duration-300 group-hover:bg-opacity-20">
            </div>
          </.link>
          <div class="top-0 right-0 absolute m-4">
            <div :for={category <- @categories} class="flex flex-col">
              <.badge
                :for={post_category <- post.categories_join_assoc}
                :if={post_category.category_id == category.id}
                variant="outline"
                class="border-white bg-white text-white bg-opacity-35 mb-2 justify-center"
              >
                <%= category.name %>
              </.badge>
            </div>
          </div>
          <.dropdown_menu
            :if={@current_user && @current_user.id == post.user_id}
            class="absolute top-0 flex m-4"
          >
            <.dropdown_menu_trigger>
              <.button
                aria-haspopup="true"
                size="icon"
                variant="ghost"
                class="text-white hover:text-zinc-700"
              >
                <Lucideicons.ellipsis class="h-6 w-6" />
                <span class="sr-only">Toggle menu</span>
              </.button>
            </.dropdown_menu_trigger>
            <.dropdown_menu_content align="start">
              <.menu>
                <.menu_label>Actions</.menu_label>
                <.menu_item>
                  <.link patch={~p"/posts/#{post}/edit"} class="flex items-center space-x-2">
                    <.icon name="hero-pencil-square" class="text-blue-400 w-4 h-4 sm:w-5 sm:h-5" />
                    <span class="text-sm sm:text-base">Edit</span>
                  </.link>
                </.menu_item>
                <.menu_item>
                  <.link
                    phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
                    data-confirm="Are you sure?"
                    class="flex items-center space-x-2"
                  >
                    <.icon name="hero-trash" class="text-red-400 w-4 h-4 sm:w-5 sm:h-5" />
                    <span class="text-sm sm:text-base">Delete</span>
                  </.link>
                </.menu_item>
              </.menu>
            </.dropdown_menu_content>
          </.dropdown_menu>
          <div
            :for={profile <- @profiles}
            :if={profile && profile.user_id == post.user_id}
            class="absolute bottom-0 flex p-3 bg-white dark:bg-gray-900"
            a
          >
            <img
              class="object-cover object-center w-10 h-10 rounded-full"
              src={profile.avatar}
              alt=""
            />
            <div class="mx-4">
              <h1 class="text-sm text-gray-700 dark:text-gray-200">
                <%= profile.first_name %> <%= profile.last_name %>
              </h1>
              <p class="text-sm text-gray-500 dark:text-gray-400">
                <%= profile.occupation %>
              </p>
            </div>
          </div>
        </div>
        <div class="flex justify-between mt-4 mr-4 ">
          <div class="justify-start flex flex-row gap-5 items-center text-sm text-zinc-400">
            <div :if={post.page_views > 0} class=" flex gap-1">
              <Lucideicons.eye class="h-4 w-4" /> <%= post.page_views %>
            </div>
            <div :if={post.like_count > 0} class=" flex gap-1 items-center">
              <Lucideicons.heart class="h-4 w-4" /> <%= post.like_count %>
            </div>
            <div :if={post.bookmark_count > 0} class=" flex gap-1 items-center">
              <.icon name="hero-bookmark" class="h-4 w-4" /> <%= post.bookmark_count %>
            </div>
            <div :if={post.comment_count > 0} class=" flex gap-1 items-center">
              <.icon name="hero-chat-bubble-oval-left" class="w-4 h-4" /> <%= post.comment_count %>
            </div>
          </div>
          <div class="flex gap-4">
            <%= if @current_user do %>
              <%= if post.bookmarked_by_user do %>
                <button phx-click="unbookmark" phx-value-id={post.id}>
                  <.icon name="hero-bookmark-solid" class="text-blue-400" />
                </button>
              <% else %>
                <button phx-click="bookmark" phx-value-id={post.id}>
                  <.icon name="hero-bookmark" class="text-blue-500" />
                </button>
              <% end %>
            <% else %>
              <.link phx-click={show_modal("sign-in")}>
                <.icon name="hero-bookmark" class="text-blue-500" />
              </.link>
            <% end %>
          </div>
        </div>
        <div class="flex flex-col flex-grow relative pt-2 mb-4">
          <div class="text-xs text-zinc-500">
            <%= Calendar.strftime(post.inserted_at, "%B %d, %Y") %>
          </div>
          <div class="h-20 mb-2">
            <!-- Fixed height for title area -->
            <.link navigate={~p"/posts/#{post}"}>
              <h1 class="text-xl font-semibold text-gray-800 dark:text-white line-clamp-2">
                <%= post.title %>
              </h1>
            </.link>
          </div>

          <hr class="w-32 absolute top-[110px] left-0 border-t-1 border-blue-500" />
          <%!--   <p class="text-sm text-gray-500 dark:text-gray-400 flex-grow mt-4"> --%>
          <%!--     <%= truncate(post.body, 20) |> MDEx.to_html!() |> raw() %> --%>
          <%!--   </p> --%>
          <%!--   <.link --%>
          <%!--     navigate={~p"/posts/#{post}"} --%>
          <%!--     class="inline-block mt-2 text-blue-500 underline hover:text-blue-400" --%>
          <%!--   > --%>
          <%!--     Read more --%>
          <%!--   </.link> --%>
        </div>
      </div>
    </div>

    <.modal :if={@live_action in [:new, :edit]} id="post-modal" show on_cancel={JS.patch(@patch)}>
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

    <.search_modal
      :if={@live_action == :search}
      id="search-post-modal"
      show
      on_cancel={JS.patch(@patch)}
    >
      <.live_component
        module={CongaWeb.SearchLive.SearchComponent}
        id={:search}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        posts={@posts}
        patch={~p"/posts"}
      />
    </.search_modal>

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
    categories = Conga.Posts.Category.list_all!()

    {:ok,
     socket
     |> assign(:posts, [])
     |> assign_new(:current_user, fn -> nil end)
     |> assign(:current_category, nil)
     |> assign(:profiles, [])
     |> assign(:categories, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    patch = apply_patch(socket)

    post =
      Ash.get!(Conga.Posts.Post, id, actor: socket.assigns.current_user)
      |> Ash.load!([
        :categories_join_assoc,
        :categories,
        :user,
        :pictures
      ])

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
    |> assign(:patch, patch)
  end

  defp apply_action(socket, :new, _params) do
    patch = apply_patch(socket)

    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, nil)
    |> assign(:patch, patch)
  end

  defp apply_action(socket, :index, _params) do
    current_user = socket.assigns.current_user
    posts = fetch_posts(socket, current_user)

    profiles =
      Enum.map(posts, & &1.user)
      |> Ash.load!([:profile])
      |> Enum.map(& &1.profile)

    # IO.inspect(profiles, label: "profiles")

    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
    |> assign(:profiles, profiles)
    |> assign(:current_category, nil)
    |> assign(:posts, posts)
    |> stream(:posts, posts, reset: true)
  end

  defp apply_action(socket, :search, _params) do
    patch = apply_patch(socket)

    socket
    |> assign(:page_title, "Search")
    |> assign(:posts, nil)
    |> assign(:patch, patch)
  end

  defp apply_action(socket, :filter_by_category, %{"category" => category_id}) do
    category = Enum.find(socket.assigns.categories, &(&1.id == category_id))
    posts = fetch_posts(socket, socket.assigns.current_user, category_id)

    socket
    |> assign(:page_title, "Category: #{category.name}")
    |> assign(:current_category, category_id)
    |> assign(:posts, posts)
    |> stream(:posts, posts, reset: true)
  end

  @impl true
  def handle_info({CongaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    categories = Conga.Posts.Category.list_all!(actor: socket.assigns.current_user)

    post =
      post
      |> Ash.load!([
        :categories_join_assoc,
        :like_count,
        :page_views,
        :bookmark_count,
        :comment_count,
        :pictures,
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    posts = fetch_posts(socket, socket.assigns.current_user, socket.assigns.current_category)

    {:noreply,
     socket
     |> stream_insert(:posts, post, at: 0, reset: true)
     |> assign(:categories, categories)
     |> assign(:posts, posts)}
  end

  @impl true
  def handle_event("bookmark", %{"id" => id}, socket) do
    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Conga.Posts.Post.bookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, true)
      |> Ash.load!([
        :like_count,
        :comment_count,
        :bookmark_count,
        :page_views,
        :pictures,
        :categories_join_assoc,
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    posts = fetch_posts(socket, socket.assigns.current_user, socket.assigns.current_category)

    {:noreply,
     socket
     |> assign(:posts, posts)
     |> stream_insert(:posts, post, reset: true)}
  end

  def handle_event("unbookmark", %{"id" => id}, socket) do
    post =
      Conga.Posts.Post
      |> Ash.get!(id, actor: socket.assigns.current_user)
      |> Conga.Posts.Post.unbookmark!(actor: socket.assigns.current_user)
      |> Map.put(:bookmarked_by_user, false)
      |> Ash.load!([
        :like_count,
        :comment_count,
        :bookmark_count,
        :page_views,
        :pictures,
        :categories_join_assoc,
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    posts = fetch_posts(socket, socket.assigns.current_user, socket.assigns.current_category)

    {:noreply,
     socket
     |> assign(:posts, posts)
     |> stream_insert(:posts, post, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post =
      Ash.get!(Conga.Posts.Post, id, actor: socket.assigns.current_user)
      |> Ash.load!([
        :likes,
        :comments,
        :bookmarks,
        :categories_join_assoc,
        :pictures,
        :user
      ])

    Ash.destroy!(post, actor: socket.assigns.current_user)

    {:noreply,
     socket
     |> stream_delete(:posts, post)
     |> put_flash(:info, "Post deleted successfully.")}
  end

  @impl true
  def handle_event("sort_by_popularity", _params, socket) do
    posts =
      fetch_posts(socket, socket.assigns.current_user, socket.assigns.current_category)
      |> Enum.sort_by(& &1.popularity_score, &>=/2)

    {:noreply,
     socket
     |> assign(:posts, posts)
     |> stream(:posts, posts, reset: true)}
  end

  def handle_event("sort_by_latest", _params, socket) do
    posts =
      fetch_posts(socket, socket.assigns.current_user, socket.assigns.current_category)

    # |> Enum.sort_by(& &1.inserted_at, &>=/2)

    {:noreply,
     socket
     |> assign(:posts, posts)
     |> stream(:posts, posts, reset: true)}
  end

  defp fetch_posts(socket, current_user, category_id \\ nil) do
    posts =
      Conga.Posts.Post.list_public!(actor: current_user)
      |> Ash.load!([
        :like_count,
        :comment_count,
        :bookmark_count,
        :page_views,
        :popularity_score,
        :reading_time,
        :likes,
        :comments,
        :bookmarks,
        :pictures,
        :categories_join_assoc,
        :categories,
        :user,
        liked_by_user: %{user_id: socket.assigns.current_user && socket.assigns.current_user.id},
        bookmarked_by_user: %{
          user_id: socket.assigns.current_user && socket.assigns.current_user.id
        }
      ])

    # IO.inspect(posts, label: "fetched posts")

    case category_id do
      nil ->
        posts

      category_id ->
        Enum.filter(posts, fn post ->
          Enum.any?(post.categories_join_assoc, fn cat ->
            cat.category_id == category_id
          end)
        end)
    end
  end

  def truncate(text, max_words) do
    text
    |> String.split()
    |> Enum.take(max_words)
    |> Enum.join(" ")
    |> Kernel.<>("...")
  end

  defp apply_patch(socket) do
    case socket.assigns.current_category do
      nil -> ~p"/posts"
      category_id -> ~p"/posts/category/#{category_id}"
    end
  end
end
