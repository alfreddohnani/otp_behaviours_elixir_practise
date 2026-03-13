defmodule DataStructures.ServerProcessTodo do
  alias DataStructures.ServerProcessTodo
  alias DataStructures.ServerProcess
  alias DataStructures.TodoEntry
  alias DataStructures.TodoList

  def init do
    TodoList.new()
  end

  def handle_cast({:add_entry, %TodoEntry{} = entry}, %TodoList{} = state) do
    TodoList.add_entry(state, entry)
  end

  def handle_cast({:update_entry, entry_id, key, value}, %TodoList{} = state) do
    TodoList.update_entry(state, entry_id, &Map.put(&1, key, value))
  end

  def handle_cast({:delete_entry, entry_id}, %TodoList{} = state) do
    TodoList.delete_entry(state, entry_id)
  end

  def handle_call({:entries, date}, %TodoList{} = state) do
    entries = TodoList.entries(state, date)
    {entries, state}
  end

  def start() do
    ServerProcess.start(ServerProcessTodo)
  end

  def add_entry(pid, %TodoEntry{} = entry) do
    ServerProcess.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, entry_id, key, value) do
    ServerProcess.cast(pid, {:update_entry, entry_id, key, value})
  end

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end
end
