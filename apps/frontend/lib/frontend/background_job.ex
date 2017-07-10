defmodule Frontend.BackgroundJob do
  def pid, do: :background_job

  def start_link do
    Frontend.BackgroundJob.Server.start_link name: pid()
  end

  def add(pid \\ pid(), initial_state, callback) do
    GenServer.cast(pid, {:add, initial_state, callback})
  end

  def all(pid \\ pid()) do
    GenServer.call(pid, :all)
  end

  def await_all(pid \\ pid()) do
    GenServer.call(pid, :await_all)
  end

  def update(pid \\ pid(), %{id: id, data: job}) do
    GenServer.cast(pid, {:update, %{id: id, data: job}})
  end

  def delete_all(pid \\ pid()) do
    GenServer.cast(pid, :delete_all)
  end
end
