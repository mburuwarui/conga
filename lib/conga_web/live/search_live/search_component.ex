defmodule CongaWeb.SearchLive.SearchComponent do
  require Ash.Query
  use CongaWeb, :live_component

  import SaladUI.Card
  import Ecto.Query, warn: false
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_search
        for={@form}
        id="searchbox_container"
        phx-change="search"
        phx-target={@myself}
        phx-debounce="300"
        phx-hook="SearchBar"
      >
        <.input_core
          field={@form[:query]}
          type="search"
          id="search-input"
          placeholder="Search for posts"
          autofocus="true"
        />
      </.simple_search>

      <%= if @posts do %>
        <.card
          :for={post <- @posts}
          class="shadow-none rounded-none border-none"
          id="searchbox__results_list"
        >
          <.link
            navigate={~p"/posts/#{post}"}
            class="focus:outline-none focus:bg-slate-100 focus:text-sky-800"
          >
            <.card_content class="flex flex-row mb-2 gap-2 space-x-2 rounded-md px-4 py-2 bg-zinc-100 hover:bg-zinc-600 hover:text-white">
              <Lucideicons.file class="h-5 w-5 text-zinc-400" />
              <%= post.title %>
            </.card_content>
          </.link>
        </.card>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => ""}}, socket) do
    {:noreply,
     socket
     |> assign(:posts, [])}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    # posts = Conga.Posts.Post.search_posts!(query, actor: socket.assigns.current_user)
    # posts =
    #   Conga.Posts.Post
    #   |> Ash.Query.filter(title: query)
    #   |> Ash.Query.sort(inserted_at: :desc)
    #   |> Ash.Query.limit(5)
    #   |> Ash.read!(actor: socket.assigns.current_user)

    search_query = "%#{query}%"

    posts =
      Conga.Posts.Post
      |> order_by(asc: :title)
      |> where([p], ilike(p.title, ^search_query))
      |> limit(5)
      |> Conga.Repo.all()

    {:noreply,
     socket
     |> assign(:posts, posts)}
  end

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_read(Conga.Posts.Post, :search_posts,
        as: "search",
        actor: socket.assigns.current_user
      )

    assign(socket, form: to_form(form))
  end
end
