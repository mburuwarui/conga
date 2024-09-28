# This watcher uses dev deps so let's only define it in dev to
# avoid warnings during compilation in production.
if Mix.env() == :dev do
  defmodule GleamBuilder do
    @gleam_dirs ["assets/hooks/src", "assets/hooks/test"]

    def start_link(_args \\ nil) do
      GenServer.start_link(__MODULE__, nil)
    end

    def init(_args) do
      # Watch for changes to Gleam files
      {:ok, pid} = FileSystem.start_link(dirs: @gleam_dirs)
      FileSystem.subscribe(pid)

      # Run the compiler once for the initial code
      run_gleam_compiler()
      {:ok, nil}
    end

    def handle_info({:file_event, _watcher, _event}, state) do
      # A Gleam file has changed, run the compiler
      run_gleam_compiler()
      {:noreply, state}
    end

    def run_gleam_compiler() do
      System.cmd("gleam", ["build"],
        cd: "assets/hooks",
        into: IO.stream(:stdio, :line),
        stderr_to_stdout: true
      )
    end
  end
end
