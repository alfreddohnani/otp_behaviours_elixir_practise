defmodule DataStructures.TodoDbSupervisor do
  alias DataStructures.TodoDatabaseWorker
  @pool_size 3
  @db_folder "./persist"

  def start_link do
    IO.puts("Starting todo database supervisor")
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    Supervisor.child_spec(
      {TodoDatabaseWorker, {@db_folder, worker_id}},
      id: worker_id
    )
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
