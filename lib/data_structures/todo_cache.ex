defmodule DataStructures.TodoCache do
  alias DataStructures.TodoDatabase
  alias DataStructures.GenServerTodoList
  use GenServer

  @impl GenServer
  def init(_) do
    TodoDatabase.start()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _from, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = GenServerTodoList.start(todo_list_name)

        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end
  end

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(todo_cache_pid, todo_list_name) do
    GenServer.call(todo_cache_pid, {:server_process, todo_list_name})
  end
end
