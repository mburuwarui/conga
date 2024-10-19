# Conga

# Building Real-time Apps with BEAM, Phoenix LiveView, and Ash Framework

## The BEAM: Erlang's Secret Weapon

The BEAM (Bogdan/Björn's Erlang Abstract Machine) is the virtual machine at the heart of the Erlang runtime system. It's designed to excel at concurrency and distributed computing, making it perfect for building scalable, fault-tolerant applications.

### Key BEAM Principles

1. **Lightweight Processes**: Not OS processes, but incredibly efficient Erlang processes.
2. **Message Passing**: Processes communicate via asynchronous message passing, avoiding shared state.
3. **Fault Tolerance**: Processes can monitor each other and restart if failures occur.
4. **Soft Real-time**: Predictable latency and garbage collection.

## Phoenix LiveView: Real-time for the Masses

Phoenix LiveView leverages the BEAM's concurrency model to provide real-time updates to web applications with minimal effort.

### How LiveView Shines

- **WebSocket-based**: Establishes a persistent connection for instant updates.
- **Server-rendered**: Reduces JavaScript complexity on the client.
- **Seamless State Management**: Keeps server and client state in sync effortlessly.

## Ash Framework: Streamlined Application Design

Ash Framework provides a declarative way to define resources and their interactions, perfectly complementing the BEAM's principles.

### Ash Framework Benefits

- **Declarative Resource Definitions**: Clearly specify entities and their relationships.
- **Built-in APIs**: Automatically generate REST and GraphQL APIs.
- **Extensible**: Add custom actions and behaviors as needed.

## Putting It All Together

By combining these technologies, you can build a real-time application that:

1. Utilizes BEAM's concurrency for handling many simultaneous connections.
2. Employs LiveView for instant UI updates without complex client-side code.
3. Uses Ash Framework to define a clear domain model and streamline API creation.

### Example: Real-time Chat Application

```elixir
defmodule MyApp.Chats.Chat do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

      postgres do
    table "profiles"
    repo MyApp.Repo
  end

  actions do
     defaults [:create, :update, :read, :destroy]
  end

  attributes do
    uuid_primary_key :id
    attribute :mesage, :string
    timestamps()
  end
end

defmodule MyApp.ChatLive do
  use MyAppWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form
          for={@form}
          id="chat-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input field={@form[:message]} label="Message" />
          <:actions>
            <.button phx-disable-with="Saving...">Save Chat</.button>
          </:actions>
        </.simple_form>
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
  def handle_event("validate", %{"message" => message_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, message_params))}
  end

  @impl true
  def handle_event("save", %{"message" => message_params}, socket) do

    case AshPhoenix.Form.submit(socket.assigns.form, params: message_params) do
      {:ok, message} ->
        notify_parent({:saved, message})

        socket =
          socket
          |> put_flash(:info, "Message #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{meesage: message}} = socket) do
    IO.inspect(message, label: "assign_form_message")

    form =
      if message do
        AshPhoenix.Form.for_update(message, :update,
          as: "message",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(MyApp.Chats.Chat, :create,
          as: "message",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

end
```

This example demonstrates how the BEAM's concurrency model, Phoenix LiveView's real-time capabilities, and Ash Framework's resource definitions come together to create a responsive, real-time chat application with minimal code.

By embracing these technologies and principles, you can build scalable, real-time applications that leverage the full power of the BEAM ecosystem.
