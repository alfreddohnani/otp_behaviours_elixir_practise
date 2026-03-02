defmodule Concurrency.Concurrency do
  def run_query(query) do
    Process.sleep(:timer.seconds(5))
    "#{query} result"
  end

  def async_query(query) do
    caller = self()

    spawn(fn ->
      query_result = run_query(query)
      send(caller, {:query_result, query_result})
    end)
  end

  def get_result() do
    receive do
      {:query_result, query_result} ->
        query_result
    after
      :timer.seconds(15) -> IO.puts("No message received...shutting off.")
    end
  end

  def run do
    1..5
    |> Enum.map(&async_query("query #{&1}"))
    |> IO.inspect(label: "PIDS")
    |> Enum.map(fn _ -> get_result() end)
    |> IO.inspect(label: "results")
  end
end
