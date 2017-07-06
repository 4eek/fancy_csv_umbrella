defmodule Frontend.BackgroundJob do
  @name :background_job

  def start_link do
    Frontend.BackgroundJob.Server.start_link name: @name
  end

  def add(pid \\ @name, initial_state, callback) do
    GenServer.cast(pid, {:add, initial_state, callback})
  end

  def all(pid \\ @name) do
    GenServer.call(pid, :all)
  end

  def await_all(pid \\ @name) do
    GenServer.call(pid, :await_all)
  end

  def update(pid \\ @name, id, data) do
    GenServer.cast(pid, {:update, id, data})
  end
end
