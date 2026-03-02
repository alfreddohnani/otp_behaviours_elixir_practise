defmodule DataStructures.TodoServer do
  alias DataStructures.TodoEntry
  alias DataStructures.TodoList

  def start do
    state = TodoList.new()
    spawn(fn -> loop(state) end)
  end

  defp loop(%TodoList{} = state) do
    new_state =
      receive do
        message -> process_message(state, message)
      end

    loop(new_state)
  end

  defp process_message(%TodoList{} = state, {:add_entry, %TodoEntry{} = entry}) do
    TodoList.add_entry(state, entry)
  end

  defp process_message(%TodoList{} = state, {:entries, caller, date}) do
    entries = TodoList.entries(state, date)
    send(caller, {:entries, entries})
    state
  end

  defp process_message(%TodoList{} = state, {:update_entry, entry_id, [{k, v}]}) do
    TodoList.update_entry(state, entry_id, &Map.put(&1, k, v))
  end

  defp process_message(%TodoList{} = state, {:delete_entry, entry_id}) do
    TodoList.delete_entry(state, entry_id)
  end

  defp process_message(%TodoList{} = state, invalid_message) do
    IO.puts("invalid message #{inspect(invalid_message)}")
    state
  end

  def add_entry(server_pid, %TodoEntry{} = entry) do
    send(server_pid, {:add_entry, entry})
  end

  def entries(server_pid, date) do
    send(server_pid, {:entries, self(), date})

    receive do
      {:entries, entries} -> {:ok, entries}
    after
      :timer.seconds(5) -> {:error, :timeout}
    end
  end

  def update_entry(server_pid, entry_id, [{k, v}]) do
    send(server_pid, {:update_entry, entry_id, [{k, v}]})
  end

  def delete_entry(server_pid, entry_id) do
    send(server_pid, {:delete_entry, entry_id})
  end
end

alias DataStructures.TodoServer
alias DataStructures.TodoEntry

server_pid = TodoServer.start()

TodoServer.add_entry(server_pid, %DataStructures.TodoEntry{
  date: ~D[2026-02-27],
  title: "Learn Elixir"
})

TodoServer.add_entry(server_pid, %DataStructures.TodoEntry{
  date: ~D[2026-03-27],
  title: "Study Kotlin"
})

TodoServer.add_entry(server_pid, %DataStructures.TodoEntry{
  date: ~D[2026-04-27],
  title: "Practise Rust"
})

IO.inspect(TodoServer.entries(server_pid, ~D[2026-02-27]))

TodoServer.update_entry(server_pid, 1, title: "Learn Elixir and Erlang")

IO.inspect(TodoServer.entries(server_pid, ~D[2026-02-27]))
