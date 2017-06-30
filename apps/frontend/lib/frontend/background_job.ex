defmodule Frontend.BackgroundJob do
  @name :job_tracker

  def start_link do
    Frontend.BackgroundJob.Server.start_link name: @name
  end

  def add(pid \\ @name, callback) do
    GenServer.cast(pid, {:add, callback})
  end

  def all(pid \\ @name) do
    GenServer.call(pid, :all)
  end

  def update(pid \\ @name, data) do
    GenServer.cast(pid, {:update, data})
  end
end
