defmodule DataStructures.Calculator do
  def start do
    spawn(fn ->
      state = 0
      loop(state)
    end)
  end

  defp loop(state) do
    new_state =
      receive do
        message -> process_message(state, message)
      end

    loop(new_state)
  end

  defp process_message(state, {:add, value}), do: state + value
  defp process_message(state, {:sub, value}), do: state - value
  defp process_message(state, {:mul, value}), do: state * value
  defp process_message(state, {:div, value}), do: state / value

  defp process_message(state, {:state, caller}) do
    send(caller, {:state, state})
    state
  end

  defp process_message(state, invalid_request) do
    IO.puts("invalid request #{inspect(invalid_request)}")
    state
  end

  def value(calc_pid) do
    send(calc_pid, {:state, self()})

    receive do
      {:state, value} -> {:ok, value}
    after
      :timer.seconds(5) -> {:error, :timeout}
    end
  end

  def add(calc_pid, value) do
    send(calc_pid, {:add, value})
  end

  def sub(calc_pid, value) do
    send(calc_pid, {:sub, value})
  end

  def mul(calc_pid, value) do
    send(calc_pid, {:mul, value})
  end

  def div(calc_div, value) do
    send(calc_div, {:div, value})
  end
end
