defmodule DataStructures.TodoDatabaseWorker do
  use GenServer

  def start_link(db_folder: db_folder) do
    IO.puts("Starting todo database worker")

    GenServer.start_link(
      __MODULE__,
      db_folder
    )
  end

  def store(db_worker_id, key, data) do
    GenServer.cast(db_worker_id, {:store, key, data})
  end

  def get(db_worker_id, key) do
    GenServer.call(db_worker_id, {:get, key})
  end

  @impl GenServer
  @spec init(
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | char(),
              binary() | []
            )
        ) ::
          {:ok,
           %{
             db_folder:
               binary()
               | maybe_improper_list(
                   binary() | maybe_improper_list(any(), binary() | []) | char(),
                   binary() | []
                 )
           }}
  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, %{db_folder: db_folder}}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, %{db_folder: db_folder} = state) do
    key
    |> file_name(db_folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, %{db_folder: db_folder} = state) do
    data =
      case File.read(file_name(key, db_folder)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end
end
