defmodule DataStructures.TodoSystem do
  use Supervisor

  alias DataStructures.TodoDbPoolboy
  alias DataStructures.TodoProcessRegistry
  alias DataStructures.TodoCache
  alias DataStructures.TodoWeb

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl Supervisor
  def init(_) do
    Supervisor.init(
      [
        TodoProcessRegistry,
        TodoDbPoolboy,
        TodoCache,
        TodoWeb
        # TodoMetrics
      ],
      strategy: :one_for_one
    )
  end
end
