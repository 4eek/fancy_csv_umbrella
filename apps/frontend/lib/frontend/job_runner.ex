defmodule Frontend.JobRunner do
  @name :job_runner

  def start_link do
    JobRunner.start_link name: @name
  end

  def add(pid \\ @name, initial_state, callback) do
    JobRunner.add(pid, initial_state, callback)
  end

  def all(pid \\ @name) do
    JobRunner.all(pid)
  end

  def await_all(pid \\ @name) do
    JobRunner.await_all(pid)
  end

  def update(pid \\ @name, options) do
    JobRunner.update(pid, options)
  end

  def delete_all(pid \\ @name) do
    JobRunner.delete_all(pid)
  end
end
