defmodule DataStructures.CsvImporter do
  alias DataStructures.TodoEntry
  alias DataStructures.TodoList
  @todos_path Path.expand("../../todos", __DIR__)

  def import(path) do
    Path.expand(@todos_path)
    |> Path.join(path)
    |> File.stream!()
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date_string, title] ->
      date = Date.from_iso8601!(date_string)
      %TodoEntry{date: date, title: String.trim_trailing(title, "\n")}
    end)
    |> TodoList.new()
  end
end
