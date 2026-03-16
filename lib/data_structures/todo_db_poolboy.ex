defmodule DataStructures.TodoDbPoolboy do
  alias DataStructures.TodoDatabaseWorker

  def child_spec(_) do
    db_folder = Application.fetch_env!(:data_structures, :db_folder)
    File.mkdir_p!(db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: TodoDatabaseWorker,
        size: 3
      ],
      db_folder: db_folder
    )
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        TodoDatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        TodoDatabaseWorker.get(worker_pid, key)
      end
    )
  end
end
