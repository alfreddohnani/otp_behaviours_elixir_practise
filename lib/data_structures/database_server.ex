defmodule DataStructures.DatabaseServer do
  alias Concurrency.Concurrency

  def start do
    spawn(&loop/0)
  end

  defp loop do
    receive do
      {:run_query, caller, query} ->
        query_result = Concurrency.run_query(query)
        send(caller, {:query_result, query_result})
    end

    loop()
  end

  def run_async(server_pid, query) do
    send(server_pid, {:run_query, self(), query})
  end

  def get_result do
    receive do
      {:query_result, query_result} -> query_result
    after
      :timer.seconds(5) -> {:error, :timeout}
    end
  end
end
