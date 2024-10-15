defmodule CongaWeb.ReturnToPlug do
  import Plug.Conn

  @invalid_return_to ["auth", "sign-in", "sign-out"]

  def init(default), do: default

  def call(conn, _default) do
    IO.puts("""
    Verb: #{inspect(conn.method)}
    Host: #{inspect(conn.query_string)}
    Headers: #{inspect(conn.request_path)}
    session: #{inspect(get_session(conn))}
    """)

    conn.request_path
    |> is_invalid_return_to()
    |> if do
      conn
    else
      put_session(conn, :return_to, add_query_parameter(conn.request_path, conn.query_string))
    end
  end

  defp is_invalid_return_to(path) do
    @invalid_return_to
    |> Enum.map(fn invalid -> String.contains?(path, invalid) end)
    |> Enum.any?()
  end

  defp add_query_parameter(path, query) do
    if query == "" do
      path
    else
      "#{path}?#{query}"
    end
  end
end
