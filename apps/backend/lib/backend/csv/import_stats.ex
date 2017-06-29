defmodule Backend.Csv.ImportStats do
  defstruct ok: 0, error: 0, message: ""

  def new, do: %__MODULE__{}

  def update(stats, :ok), do: %{stats | ok: stats.ok + 1}
  def update(stats, :error), do: %{stats | error: stats.error + 1}
  def update(stats, message: message), do: Map.merge(stats, %{message: message})
end
