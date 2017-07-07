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
    job = %__MODULE__{id: Enum.count(job_map) + 1, data: initial_data}
    task = Task.async(fn -> callback.(job.id) end)

    {:noreply, Map.put(job_map, job.id, %{job | task: task})}
  end

  def handle_cast({:update, id, data}, job_map) do
    {:noreply, put_in(job_map[id].data, Map.merge(job_map[id].data, data))}
  end

  def handle_call(:all, _from, job_map) do
    {:reply, job_map |> Map.values |> Enum.reverse, job_map}
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

