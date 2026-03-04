defmodule DataStructures.TodoDatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(db_worker_pid, key, data) do
    GenServer.cast(db_worker_pid, {:store, key, data})
  end

  def get(db_worker_pid, key) do
    GenServer.call(db_worker_pid, {:get, key})
  end

  @impl GenServer
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
