defmodule DataStructures.TodoSystem do
  use Supervisor

  alias DataStructures.TodoCache

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl Supervisor
  def init(_) do
    Supervisor.init([TodoCache], strategy: :one_for_one)
  end
end
