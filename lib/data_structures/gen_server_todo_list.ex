defmodule DataStructures.GenServerTodoList do
  use GenServer
  alias DataStructures.TodoList
  alias DataStructures.TodoEntry
  alias DataStructures.GenServerTodoList

  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, state) do
    {:noreply, TodoList.add_entry(state, entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, key, value}, state) do
    {:noreply, TodoList.update_entry(state, entry_id, &Map.put(&1, key, value))}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, state) do
    {:noreply, TodoList.delete_entry(state, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  @impl GenServer
  def handle_info(msg, state) do
    IO.puts("Unknown message: #{inspect(msg)}")
    {:noreply, state}
  end

  def start() do
    GenServer.start(GenServerTodoList, nil)
  end

  def add_entry(pid, %TodoEntry{} = entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, entry_id, key, value) do
    GenServer.cast(pid, {:update_entry, entry_id, key, value})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  @spec entries(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, any()) :: any()
  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
end
