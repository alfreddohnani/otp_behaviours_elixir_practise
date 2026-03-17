defmodule DataStructures.TodoDatabase do
  alias DataStructures.TodoDatabaseWorker
  use GenServer

  @db_folder "./persist"

  def start_link(_) do
    IO.puts("Starting todo database server")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get(key) do
    db_worker_pid = choose_worker(key)
    TodoDatabaseWorker.get(db_worker_pid, key)
  end

  def choose_worker(db_list_name) do
    GenServer.call(__MODULE__, {:choose_worker, db_list_name})
  end

  @impl GenServer
  def init(_) do
    key_pid_map =
      0..2
      |> Enum.map(fn key ->
        {:ok, db_worker_pid} = TodoDatabaseWorker.start_link(db_folder: @db_folder)
        {key, db_worker_pid}
      end)
      |> Enum.into(%{})

    IO.puts("key pid map #{inspect(key_pid_map)}")

    {:ok, key_pid_map}
  end

  @impl GenServer
  def handle_call({:choose_worker, db_list_name}, _from, state) do
    key = :erlang.phash2(db_list_name, 3)
    db_worker_pid = Map.get(state, key)

    IO.puts(
      "name: #{inspect(db_list_name)}, key: #{inspect(key)}, pid: #{inspect(db_worker_pid)}"
    )

    {:reply, db_worker_pid, state}
  end
end
