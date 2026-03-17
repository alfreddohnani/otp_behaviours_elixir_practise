defmodule DataStructures.GenServerTodoList do
  use GenServer, restart: :temporary

  alias DataStructures.TodoDbPoolboy
  alias DataStructures.TodoList
  alias DataStructures.TodoEntry

  @impl GenServer
  def init(list_name) do
    {:ok, {list_name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {list_name, nil}) do
    todo_list = TodoDbPoolboy.get(list_name) || TodoList.new()
    {:noreply, {list_name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {list_name, state}) do
    new_list = TodoList.add_entry(state, entry)
    TodoDbPoolboy.store(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, key, value}, {list_name, state}) do
    {:noreply, {list_name, TodoList.update_entry(state, entry_id, &Map.put(&1, key, value))}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {list_name, state}) do
    {:noreply, {list_name, TodoList.delete_entry(state, entry_id)}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {list_name, state}) do
    {:reply, TodoList.entries(state, date), {list_name, state}}
  end

  @impl GenServer
  def handle_info(msg, {list_name, state}) do
    IO.puts("Unknown message: #{inspect(msg)}")
    {:noreply, {list_name, state}}
  end

  defp global_name(list_name) do
    {:global, {__MODULE__, list_name}}
  end

  def start_link(list_name) do
    GenServer.start_link(__MODULE__, list_name, name: global_name(list_name))
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

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def whereis(list_name) do
    case :global.whereis_name({__MODULE__, list_name}) do
      :undefined -> nil
      pid -> pid
    end
  end
end
