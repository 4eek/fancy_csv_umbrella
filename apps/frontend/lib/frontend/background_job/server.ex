defmodule Frontend.BackgroundJob.Server do
  use GenServer

  defstruct ~w(id task data)a

  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, [], opts
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:add, initial_data, callback}, job_map) do
    data = %__MODULE__{id: Enum.count(job_map) + 1, data: initial_data}
    task = Task.async(fn -> callback.(data.id) end)

    {:noreply, Map.put(job_map, data.id, %{data | task: task})}
  end

  def handle_cast({:update, %{id: id, data: data}}, job_map) do
    data = Map.delete(data, :__struct__)

    {:noreply, put_in(job_map[id].data, Map.merge(job_map[id].data, data))}
  end

  def handle_call(:all, _from, job_map) do
    jobs_data = job_map
    |> Map.values
    |> Enum.map(&Map.delete(&1, :task))

    {:reply, jobs_data, job_map}
  end

  def handle_call(:await_all, _from, job_map) do
    job_map |> Map.values |> Enum.map(&Task.await(&1.task))

    {:reply, :ok, job_map}
  end

  def handle_info({ref, _task_result}, job_map) do
    Process.demonitor ref, [:flush]

    {:noreply, job_map}
  end
end

