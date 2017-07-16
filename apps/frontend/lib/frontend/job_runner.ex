defmodule Frontend.JobRunner do
  @name :job_runner

  def start_link, do: JobRunner.start_link name: @name

  defdelegate add(pid \\ @name, initial_state, callback), to: JobRunner
  defdelegate all(pid \\ @name), to: JobRunner
  defdelegate await_all(pid \\ @name), to: JobRunner
  defdelegate update(pid \\ @name, options), to: JobRunner
  defdelegate delete_all(pid \\ @name), to: JobRunner
end
