defmodule DataStructures.TodoList do
  alias DataStructures.TodoList
  alias DataStructures.TodoList
  alias DataStructures.TodoEntry

  defstruct next_id: 1,
            entries: %{1 => %TodoEntry{}}

  defimpl String.Chars do
    def to_string(_), do: "#TodoList"
  end

  defimpl Collectable do
    def into(original) do
      # appender lambda
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, %TodoEntry{} = entry}) do
      TodoList.add_entry(todo_list, entry)
    end

    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(_, :halt), do: :ok
  end

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
  end

  def add_entry(%TodoList{} = todo_list, %TodoEntry{} = entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.next_id,
        entry
      )

    %TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(%TodoList{} = todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  def update_entry(%TodoList{} = todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, %TodoEntry{} = old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)

        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%TodoList{} = todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end

alias DataStructures.TodoList

# todo_list =
#   TodoList.new()
#   |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist"})
#   |> TodoList.add_entry(%{date: ~D[2023-12-20], title: "Shopping"})
#   |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Movies"})

# todo_list =
# TodoList.new([
#   %{date: ~D[2023-12-19], title: "Dentist"},
#   %{date: ~D[2023-12-20], title: "Shopping"},
#   %{date: ~D[2023-12-19], title: "Movies"}
# ])

# IO.inspect(todo_list, label: "TODOS")

# TodoList.update_entry(todo_list, 1, &Map.put(&1, :date, ~D[2023-12-20]))
# |> IO.inspect(label: "UPDATED ENTRY 1")
# |> TodoList.delete_entry(1)
# |> IO.inspect(label: "AFTER DELETE")
