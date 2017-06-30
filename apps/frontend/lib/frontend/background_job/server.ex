defmodule Frontend.BackgroundJob.Server do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, [], opts
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:add, callback}, job_map) do
    job = %{id: Enum.count(job_map) + 1, task: nil}
    task = Task.async(fn -> callback.(job) end)

    {:noreply, Map.put(job_map, job.id, %{job | task: task})}
  end

  def handle_cast({:update, %{id: id} = data}, job_map) do
    {:noreply, %{job_map | id => Map.merge(job_map[id], data)}}
  end

  def handle_call(:all, _from, job_map) do
    {:reply, job_map |> Map.values |> Enum.reverse, job_map}
  end

  def handle_call(:await_all, _from, job_map) do
    job_map |> Map.values |> Enum.map(&Task.await(&1.task))

    {:reply, :ok, job_map}
  end
end

