defmodule JobRunner do
  def start_link(options \\ []) do
    JobRunner.Server.start_link options
  end

  def add(pid, initial_state, callback) do
    GenServer.cast(pid, {:add, initial_state, callback})
  end

  def all(pid) do
    GenServer.call(pid, :all)
  end

  def await_all(pid) do
    GenServer.call(pid, :await_all)
  end

  def update(pid, %{id: id, data: job}) do
    GenServer.cast(pid, {:update, %{id: id, data: job}})
  end

  def delete_all(pid) do
    GenServer.call(pid, :delete_all)
  end
end
