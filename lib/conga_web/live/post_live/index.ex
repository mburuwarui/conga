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
      Listing Posts
      <:actions>
        <div class="flex flex-row gap-4">
          <.link :if={@current_user} patch={~p"/posts/new"}>
            <.button>New Post</.button>
          </.link>
          <.link patch={~p"/search"}>
            <.button class="text-gray-500 bg-white hover:ring-gray-500 hover:text-white ring-gray-300 h-8 w-full items-center gap-10 rounded-md pl-2 pr-3 text-sm ring-1 transition lg:flex justify-between focus:[&:not(:focus-visible)]:outline-none">
              <div class="flex items-center pr-4 gap-2">
                <Lucideicons.search class="h-4 w-4 " /> Find posts
              </div>

              <kbd class="ml-auto text-3xs opacity-80">
                <kbd class="font-sans">⌘</kbd><kbd class="font-sans">K</kbd>
              </kbd>
            </.button>
          </.link>
        </div>
      </:actions>

      <div class="mb-5">
        <%!-- <h2 class="text-lg font-semibold mb-2">Filter by Category:</h2> --%>
        <div class="flex flex-wrap gap-2">
          <.link :for={category <- @categories} patch={~p"/posts/category/#{category.id}"}>
            <button class={[
              "px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
              @current_category == category.id && "bg-indigo-600 text-white",
              @current_category != category.id && "text-gray-700 bg-gray-200 hover:bg-gray-300"
            ]}>
              <%= category.name %>
            </button>
          </.link>
          <.link patch={~p"/posts"}>
            <button class={[
              "px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
              @current_category == nil && "bg-indigo-600 text-white",
              @current_category != nil && "text-gray-700 bg-gray-200 hover:bg-gray-300"
            ]}>
              All Categories
            </button>
          </.link>
        </div>
      </div>
    </.header>

    <div
      class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-4"
      phx-update="stream"
      id="posts"
    >
      <div :for={{id, post} <- @streams.posts} class="card flex flex-col h-full" id={id}>
        <div class="relative flex-shrink-0">
          <img
            class="object-cover object-center w-full h-64 rounded-lg lg:h-80"
            src="https://images.unsplash.com/photo-1597534458220-9fb4969f2df5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80"
            alt=""
          />
          <div class="absolute bottom-0 right-0 flex m-4 gap-1 text-sm text-zinc-500">
            <Lucideicons.eye class="h-4 w-4" /> <%= post.page_views %>
          </div>
          <%= for category <- @categories do %>
            <.badge
              :for={post_category <- post.categories_join_assoc}
              :if={post_category.category_id == category.id}
              variant="outline"
              class="border-zinc-400 bg-amber-100 text-zinc-600 top-0 right-0 absolute flex m-4"
            >
              <%= category.name %>
            </.badge>
          <% end %>
          <.dropdown_menu
            :if={@current_user && @current_user.id == post.user_id}
            class="absolute top-0 flex m-4"
          >
            <.dropdown_menu_trigger>
              <.button aria-haspopup="true" size="icon" variant="ghost">
                <Lucideicons.ellipsis class="h-4 w-4" />
                <span class="sr-only">Toggle menu</span>
              </.button>
            </.dropdown_menu_trigger>
            <.dropdown_menu_content align="start">
              <.menu>
                <.menu_label>Actions</.menu_label>
                <.menu_item class="justify-center">
                  <.link patch={~p"/posts/#{post}/edit"}>
                    <.icon name="hero-pencil-square" class="w-5 h-5 text-blue-500" />
                  </.link>
                </.menu_item>
                <.menu_item class="justify-center">
                  <.link
                    phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
                    data-confirm="Are you sure?"
                  >
                    <.icon name="hero-trash" class="text-red-500 w-5 h-5" />
                  </.link>
                </.menu_item>
              </.menu>
            </.dropdown_menu_content>
          </.dropdown_menu>
          <div class="absolute bottom-0 flex p-3 bg-white dark:bg-gray-900">
            <img
              class="object-cover object-center w-10 h-10 rounded-full"
              src="https://images.unsplash.com/photo-1531590878845-12627191e687?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80"
              alt=""
            />
            <div class="mx-4">
              <h1 class="text-sm text-gray-700 dark:text-gray-200">Amelia. Anderson</h1>
              <p class="text-sm text-gray-500 dark:text-gray-400">Lead Developer</p>
            </div>
          </div>
        </div>
        <div class="flex flex-col flex-grow relative pt-6">
          <div class="h-20 mb-2">
            <!-- Fixed height for title area -->
            <h1 class="text-xl font-semibold text-gray-800 dark:text-white line-clamp-2">
              <%= post.title %>
            </h1>
          </div>
          <hr class="w-32 absolute top-[104px] left-0 border-t-1 border-blue-500" />
          <p class="text-sm text-gray-500 dark:text-gray-400 flex-grow mt-4">
            <%= truncate(post.body, 20) %>
          </p>
          <.link
            navigate={~p"/posts/#{post}"}
            class="inline-block mt-4 text-blue-500 underline hover:text-blue-400"
          >
            Read more
          </.link>
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
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    categories = Conga.Posts.Category.list_all!()
    IO.inspect(categories, label: "categories")

    {:ok,
     socket
     |> assign(:posts, [])
     |> assign_new(:current_user, fn -> nil end)
     |> assign(:current_category, nil)
     |> assign(:categories, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post =
      Ash.get!(Conga.Posts.Post, id, actor: socket.assigns.current_user)
      |> Ash.load!([
        :categories_join_assoc
      ])

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
  end

  defp apply_action(socket, :new, _params) do
    patch = apply_patch(socket)

    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, nil)
    |> assign(:patch, patch)
  end

  defp apply_action(socket, :index, _params) do
    posts = fetch_posts(socket.assigns.current_user)

    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
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
    posts = fetch_posts(socket.assigns.current_user, category_id)

    socket
    |> assign(:page_title, "Category: #{category.name}")
    |> assign(:current_category, category_id)
    |> assign(:posts, posts)
    |> stream(:posts, posts, reset: true)
  end

  @impl true
  def handle_info({CongaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    categories = Conga.Posts.Category.list_all!(actor: socket.assigns.current_user)

    post = post |> Ash.load!([:categories_join_assoc])

    posts = socket.assigns.posts ++ [post]

    {:noreply,
     socket
     |> stream_insert(:posts, post, at: 0)
     |> assign(:categories, categories)
     |> assign(:posts, posts)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post =
      Ash.get!(Conga.Posts.Post, id, actor: socket.assigns.current_user)

    Ash.destroy!(post, actor: socket.assigns.current_user)

    {:noreply,
     socket
     |> stream_delete(:posts, post)
     |> put_flash(:info, "Post deleted successfully.")}
  end

  defp fetch_posts(current_user, category_id \\ nil) do
    posts =
      Conga.Posts.Post.list_public!(actor: current_user)
      |> Ash.load!([
        :total_likes,
        :page_views,
        :reading_time,
        :likes,
        :comments,
        :bookmarks,
        :categories_join_assoc,
        :user
      ])

    if category_id do
      Enum.filter(posts, fn post ->
        Enum.any?(post.categories_join_assoc, fn cat ->
          cat.category_id == category_id
        end)
      end)
    else
      posts
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
