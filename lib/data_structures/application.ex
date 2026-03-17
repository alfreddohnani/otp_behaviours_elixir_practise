defmodule DataStructures.Application do
  alias DataStructures.TodoSystem
  use Application

  @impl Application
  def start(_start_type, _start_args) do
    TodoSystem.start_link()
  end
end
