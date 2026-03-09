defmodule DataStructures.EchoServer do
  use GenServer

  def start_link(id) do
    Registry.start_link(name: :my_registry, keys: :unique)
    GenServer.start_link(__MODULE__, nil, name: via_tuple(id))
  end

  defp via_tuple(id) do
    {:via, Registry, {:my_registry, {__MODULE__, id}}}
  end

  @impl GenServer
  def init(_), do: {:ok, nil}

  def call(id, some_request) do
    GenServer.call(via_tuple(id), some_request)
  end

  @impl GenServer
  def handle_call(some_request, _from, state) do
    {:reply, some_request, state}
  end
end
