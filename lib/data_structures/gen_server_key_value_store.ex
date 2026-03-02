defmodule DataStructures.GenServerKeyValueStore do
  alias DataStructures.GenServerKeyValueStore
  use GenServer

  @impl GenServer
  def init(_) do
    # :timer.send_interval(:timer.seconds(5), :cleanup)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts("Performing cleanup...")
    {:noreply, state}
  end

  def start() do
    GenServer.start(GenServerKeyValueStore, nil)
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end
end
