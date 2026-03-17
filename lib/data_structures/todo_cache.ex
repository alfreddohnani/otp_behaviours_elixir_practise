defmodule DataStructures.TodoCache do
  alias DataStructures.GenServerTodoList

  def start_link() do
    IO.puts("Starting todo cache")

    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def server_process(todo_list_name) do
    existing_process(todo_list_name) || new_process(todo_list_name)
  end

  defp existing_process(todo_list_name) do
    GenServerTodoList.whereis(todo_list_name)
  end

  defp new_process(todo_list_name) do
    case DynamicSupervisor.start_child(
           __MODULE__,
           {GenServerTodoList, todo_list_name}
         ) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
