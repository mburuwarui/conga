defmodule CongaWeb.DemoLive.DashboardOne do
  @moduledoc false
  require Ash.Query
  use CongaWeb, :dash_view

  import SaladUI.Badge
  import SaladUI.Breadcrumb
  import SaladUI.Button
  import SaladUI.Card
  import SaladUI.DropdownMenu
  import SaladUI.Input
  import SaladUI.Menu
  import SaladUI.Sheet
  import SaladUI.Skeleton
  import SaladUI.Table
  import SaladUI.Tabs
  import SaladUI.Tooltip
  import SaladUI.Dialog

  # @impl true
  # def mount(_params, _session, socket) do
  #   {:ok, assign(socket, products: seed_products(10))}
  # end

  # defp seed_products(count) do
  #   Enum.map(1..count, fn _ ->
  #     %{
  #       id: 8 |> :crypto.strong_rand_bytes() |> Base.encode16(),
  #       name: Faker.Commerce.product_name(),
  #       status: Enum.random(~w[active draft]),
  #       price: Faker.Commerce.price(),
  #       total_sales: Enum.random(0..100),
  #       created_at: Faker.DateTime.between(~D[2023-01-01], ~D[2024-12-31])
  #     }
  #   end)
  # end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen w-full flex-col bg-muted/40">
      <aside class="fixed inset-y-0 left-0 z-10 hidden w-14 flex-col border-r bg-background sm:flex">
        <nav class="flex flex-col items-center gap-4 px-2 sm:py-5">
          <.link
            href="#"
            class="group flex h-9 w-9 shrink-0 items-center justify-center gap-2 rounded-full bg-primary text-lg font-semibold text-primary-foreground md:h-8 md:w-8 md:text-base"
          >
            <Lucideicons.package class="h-4 w-4 transition-all group-hover:scale-110" />
            <span class="sr-only">Acme Inc</span>
          </.link>
          <.tooltip>
            <.link
              href="#"
              class="flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:text-foreground md:h-8 md:w-8"
            >
              <Lucideicons.home class="h-5 w-5" />
              <span class="sr-only">Dashboard</span>
            </.link>
            <.tooltip_content side="right">Dashboard</.tooltip_content>
          </.tooltip>
          <.tooltip>
            <.link
              href="#"
              class="flex h-9 w-9 items-center justify-center rounded-lg bg-accent text-accent-foreground transition-colors hover:text-foreground md:h-8 md:w-8"
            >
              <Lucideicons.shopping_cart class="h-5 w-5" />
              <span class="sr-only">Orders</span>
            </.link>
            <.tooltip_content side="right">Orders</.tooltip_content>
          </.tooltip>
          <.tooltip>
            <.link
              href="#"
              class="flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:text-foreground md:h-8 md:w-8"
            >
              <Lucideicons.package class="h-5 w-5" />
              <span class="sr-only">Products</span>
            </.link>
            <.tooltip_content side="right">Products</.tooltip_content>
          </.tooltip>
          <.tooltip>
            <.link
              href="#"
              class="flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:text-foreground md:h-8 md:w-8"
            >
              <Lucideicons.users class="h-5 w-5" />
              <span class="sr-only">Customers</span>
            </.link>
            <.tooltip_content side="right">Customers</.tooltip_content>
          </.tooltip>
          <.tooltip>
            <.link
              href="#"
              class="flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:text-foreground md:h-8 md:w-8"
            >
              <Lucideicons.line_chart class="h-5 w-5" />
              <span class="sr-only">Analytics</span>
            </.link>
            <.tooltip_content side="right">Analytics</.tooltip_content>
          </.tooltip>
        </nav>
        <nav class="mt-auto flex flex-col items-center gap-4 px-2 sm:py-5">
          <.tooltip>
            <.link
              href="#"
              class="flex h-9 w-9 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:text-foreground md:h-8 md:w-8"
            >
              <Lucideicons.settings class="h-5 w-5" />
              <span class="sr-only">Settings</span>
            </.link>
            <.tooltip_content side="right">Settings</.tooltip_content>
          </.tooltip>
        </nav>
      </aside>
      <div class="flex flex-col sm:gap-4 sm:py-4 sm:pl-14">
        <header class="sticky top-0 z-30 flex h-14 items-center gap-4 border-b bg-background px-4 sm:static sm:h-auto sm:border-0 sm:bg-transparent sm:px-6">
          <.sheet>
            <.sheet_trigger target="sheet">
              <.button size="icon" variant="outline" class="sm:hidden">
                <Lucideicons.panel_left class="h-5 w-5" />
                <span class="sr-only">Toggle Menu</span>
              </.button>
            </.sheet_trigger>
            <.sheet_content id="sheet" side="left" class="sm:max-w-xs">
              <nav class="grid gap-6 text-lg font-medium">
                <.link
                  href="#"
                  class="group flex h-10 w-10 shrink-0 items-center justify-center gap-2 rounded-full bg-primary text-lg font-semibold text-primary-foreground md:text-base"
                >
                  <Lucideicons.package class="h-5 w-5 transition-all group-hover:scale-110" />
                  <span class="sr-only">Acme Inc</span>
                </.link>
                <.link
                  href="#"
                  class="flex items-center gap-4 px-2.5 text-muted-foreground hover:text-foreground"
                >
                  <Lucideicons.home class="h-5 w-5" /> Dashboard
                </.link>
                <.link
                  href="#"
                  class="flex items-center gap-4 px-2.5 text-muted-foreground hover:text-foreground"
                >
                  <Lucideicons.shopping_cart class="h-5 w-5" /> Orders
                </.link>
                <.link href="#" class="flex items-center gap-4 px-2.5 text-foreground">
                  <Lucideicons.package class="h-5 w-5" /> Posts
                </.link>
                <.link
                  href="#"
                  class="flex items-center gap-4 px-2.5 text-muted-foreground hover:text-foreground"
                >
                  <Lucideicons.users class="h-5 w-5" /> Customers
                </.link>

                <.link
                  href="#"
                  class="flex items-center gap-4 px-2.5 text-muted-foreground hover:text-foreground"
                >
                  <Lucideicons.line_chart class="h-5 w-5" /> Settings
                </.link>
              </nav>
            </.sheet_content>
          </.sheet>
          <.breadcrumb class="hidden md:flex">
            <.breadcrumb_list>
              <.breadcrumb_item>
                <.breadcrumb_link>
                  <.link href="#"></.link>Dashboard
                </.breadcrumb_link>
              </.breadcrumb_item>
              <.breadcrumb_separator />
              <.breadcrumb_item>
                <.breadcrumb_link>
                  <.link href="#"></.link>Posts
                </.breadcrumb_link>
              </.breadcrumb_item>
              <.breadcrumb_separator />
              <.breadcrumb_item>
                <.breadcrumb_page>All Posts</.breadcrumb_page>
              </.breadcrumb_item>
            </.breadcrumb_list>
          </.breadcrumb>
          <div class="relative ml-auto flex-1 md:grow-0">
            <Lucideicons.search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <.input
              type="text"
              placeholder="Search..."
              class="w-full rounded-lg bg-background pl-8 md:w-[200px] lg:w-[336px]"
            />
          </div>
          <.dropdown_menu>
            <.dropdown_menu_trigger>
              <.button variant="outline" size="icon" class="overflow-hidden rounded-full">
                <img
                  src={~p"/images/logo.svg"}
                  width="{36}"
                  height="{36}"
                  alt="Avatar"
                  class="overflow-hidden rounded-full"
                />
              </.button>
            </.dropdown_menu_trigger>
            <.dropdown_menu_content align="end">
              <.menu>
                <.menu_label>My Account</.menu_label>
                <.menu_separator />
                <.menu_item>Settings</.menu_item>
                <.menu_item>Support</.menu_item>
                <.menu_separator />
                <.menu_item>Logout</.menu_item>
              </.menu>
            </.dropdown_menu_content>
          </.dropdown_menu>
        </header>
        <main class="grid flex-1 items-start gap-4 p-4 sm:px-6 sm:py-0 md:gap-8">
          <.tabs default="all" id="tabs">
            <div class="flex items-center">
              <.tabs_list>
                <.tabs_trigger value="all" root="tabs">All</.tabs_trigger>
                <.tabs_trigger value="active" root="tabs">Active</.tabs_trigger>
                <.tabs_trigger value="draft" root="tabs">Draft</.tabs_trigger>
                <.tabs_trigger value="archived" root="tabs" class="hidden sm:flex">
                  Archived
                </.tabs_trigger>
              </.tabs_list>
              <div class="ml-auto flex items-center gap-2">
                <.dropdown_menu>
                  <.dropdown_menu_trigger>
                    <.button variant="outline" size="sm" class="h-8 gap-1">
                      <Lucideicons.list_filter class="h-3.5 w-3.5" />
                      <span class="sr-only sm:not-sr-only sm:whitespace-nowrap">
                        Filter
                      </span>
                    </.button>
                  </.dropdown_menu_trigger>
                  <.dropdown_menu_content align="end">
                    <.menu>
                      <.menu_label>Filter by</.menu_label>
                      <.menu_separator />
                      <.menu_item>
                        Active
                      </.menu_item>
                      <.menu_item>Draft</.menu_item>
                      <.menu_item>
                        Archived
                      </.menu_item>
                    </.menu>
                  </.dropdown_menu_content>
                </.dropdown_menu>
                <.button size="sm" variant="outline" class="h-8 gap-1">
                  <Lucideicons.file class="h-3.5 w-3.5" />
                  <span class="sr-only sm:not-sr-only sm:whitespace-nowrap">
                    Export
                  </span>
                </.button>
                <.link :if={@current_user} patch={~p"/dashboard/posts/new"}>
                  <.button size="sm" class="h-8 gap-1">
                    <Lucideicons.circle_plus class="h-3.5 w-3.5" />
                    <span class="sr-only sm:not-sr-only sm:whitespace-nowrap">
                      Add Post
                    </span>
                  </.button>
                </.link>
              </div>
            </div>
            <.tabs_content value="all">
              <.card>
                <.card_header>
                  <.card_title>Posts</.card_title>
                  <.card_description>
                    Manage your posts and view their sales performance.
                  </.card_description>
                </.card_header>
                <.card_content>
                  <.table id="posts">
                    <.table_header class="text-zinc-200">
                      <.table_row>
                        <.table_head class="hidden w-[100px] sm:table-cell"></.table_head>
                        <.table_head>Title</.table_head>
                        <.table_head>Body</.table_head>
                        <.table_head class="hidden md:table-cell">
                          Category
                        </.table_head>
                        <.table_head class="hidden md:table-cell">
                          Reading Time
                        </.table_head>
                        <.table_head class="hidden md:table-cell">
                          Created at
                        </.table_head>
                        <.table_head>
                          <span class="sr-only">Actions</span>
                        </.table_head>
                      </.table_row>
                    </.table_header>
                    <.table_body phx-update="stream" class="text-zinc-700">
                      <.table_row :for={{id, post} <- @streams.posts} id={id}>
                        <.table_cell class="hidden sm:table-cell">
                          <.skeleton class="h-16 w-16" />
                        </.table_cell>
                        <.table_cell class="font-medium">
                          <%= post.title %>
                        </.table_cell>
                        <.table_cell>
                          <%= post.body %>
                        </.table_cell>
                        <.table_cell class="hidden md:table-cell">
                          <.badge variant="outline" class="border-yellow-400">
                            <%= post.category %>
                          </.badge>
                        </.table_cell>
                        <.table_cell class="hidden md:table-cell">
                          <%= post.reading_time %>
                        </.table_cell>
                        <.table_cell
                          phx-hook="LocalTime"
                          id={"inserted_at-#{post.inserted_at}"}
                          class="hidden md:table-cell invisible"
                        >
                          <%= DateTime.to_string(post.inserted_at) %>
                        </.table_cell>
                        <.table_cell class=" sm:table-cell">
                          <.link navigate={~p"/posts/#{post}"}>
                            <Lucideicons.eye class="h-5 w-5 text-blue-500" />
                          </.link>
                        </.table_cell>
                        <.table_cell>
                          <.dropdown_menu>
                            <.dropdown_menu_trigger>
                              <.button aria-haspopup="true" size="icon" variant="ghost">
                                <Lucideicons.ellipsis class="h-4 w-4" />
                                <span class="sr-only">Toggle menu</span>
                              </.button>
                            </.dropdown_menu_trigger>
                            <.dropdown_menu_content align="end">
                              <.menu>
                                <%!-- <.menu_label>Actions</.menu_label> --%>
                                <.menu_item class="justify-center">
                                  <.link patch={~p"/dashboard/posts/#{post}/edit"}>
                                    <.icon name="hero-pencil-square" class="w-5 h-5 text-blue-500" />
                                  </.link>
                                </.menu_item>
                                <.menu_item class="justify-center">
                                  <.link
                                    phx-click={
                                      JS.push("delete", value: %{id: post.id}) |> hide("##{id}")
                                    }
                                    data-confirm="Are you sure?"
                                  >
                                    <.icon name="hero-trash" class="text-red-500 w-5 h-5" />
                                  </.link>
                                </.menu_item>
                              </.menu>
                            </.dropdown_menu_content>
                          </.dropdown_menu>
                        </.table_cell>
                      </.table_row>
                    </.table_body>
                  </.table>
                </.card_content>
                <.modal
                  :if={@live_action in [:new, :edit]}
                  id="post-modal"
                  show
                  on_cancel={JS.patch(~p"/dashboard/posts")}
                >
                  <.live_component
                    module={CongaWeb.PostLive.FormComponent}
                    id={(@post && @post.id) || :new}
                    title={@page_title}
                    current_user={@current_user}
                    action={@live_action}
                    post={@post}
                    patch={~p"/dashboard/posts"}
                  />
                </.modal>
                <.card_footer>
                  <div class="text-xs text-muted-foreground">
                    Showing <strong>1-10</strong> of <strong>32</strong> posts
                  </div>
                </.card_footer>
              </.card>
            </.tabs_content>
          </.tabs>
        </main>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    posts =
      Conga.Posts.Post.list_dashboard!(actor: current_user)
      |> Ash.load!([:total_likes, :reading_time, :likes, :comments, :bookmarks, :user])

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
    post =
      post
      |> Ash.load!([:total_likes, :reading_time, :likes, :comments, :bookmarks, :user])

    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post =
      Ash.get!(Conga.Posts.Post, id, actor: socket.assigns.current_user)

    Ash.destroy!(post, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end
