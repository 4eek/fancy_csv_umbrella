defmodule JobRunner.Impl do
  defstruct ~w(id task data)a

  def new, do: %{}

  def add(job_map, initial_data, callback) do
    id = Enum.count(job_map) + 1
    task = Task.async(fn -> callback.(id) end)
    data = %__MODULE__{id: id, data: initial_data, task: task}

    Map.put(job_map, id, data)
  end

  def update(job_map, %{id: id, data: data}) do
    new_data = data |> Map.delete(:__struct__)
    data = job_map[id].data |> Map.merge(new_data)

    put_in(job_map[id].data, data)
  end

  def delete_all(_job_map), do: %{}

  def all(job_map) do
    job_map
    |> Map.values
    |> Enum.map(&Map.delete(&1, :task))
  end

  def await_all(job_map) do
    job_map |> Map.values |> Enum.map(&Task.await(&1.task))
    job_map
  end

  def finish_job(ref, job_map) do
    Process.demonitor ref, [:flush]
    job_map
  end
end
