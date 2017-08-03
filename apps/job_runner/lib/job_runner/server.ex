defmodule JobRunner.Server do
  alias JobRunner.Impl
  use GenServer

  def start_link(opts \\ []), do: GenServer.start_link __MODULE__, [], opts
  def init(_), do: {:ok, Impl.new}

  def handle_cast({:add, data, callback}, job_map), do: {:noreply, Impl.add(job_map, data, callback)}
  def handle_cast({:update, data}, job_map), do: {:noreply, Impl.update(job_map, data)}

  def handle_call(:all, _from, job_map), do: {:reply, Impl.all(job_map), job_map}
  def handle_call(:delete_all, _from, job_map), do: {:reply, nil, Impl.delete_all(job_map)}
  def handle_call(:await_all, _from, job_map), do: {:reply, :ok, Impl.await_all(job_map)}

  def handle_info({ref, _task_result}, job_map), do: {:noreply, Impl.finish_job(ref, job_map)}
  def handle_info(_, job_map), do: {:noreply, job_map}
end
