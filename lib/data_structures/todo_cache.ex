defmodule DataStructures.TodoCache do
  alias DataStructures.GenServerTodoList
  use GenServer

  @impl GenServer
  def init(_) do
    IO.puts("Starting todo cache.")
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _from, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = GenServerTodoList.start_link(todo_list_name)

        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    IO.puts("Starting todo server process for #{todo_list_name}")
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end
end
