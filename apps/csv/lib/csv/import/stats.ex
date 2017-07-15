defmodule Csv.Import.Stats do
  defstruct ok: 0, error: 0, output: nil, message: nil

  def new, do: %__MODULE__{}

  def update(stats, :ok), do: %{stats | ok: stats.ok + 1}
  def update(stats, :error), do: %{stats | error: stats.error + 1}
  def update(stats, output: output), do: %{stats | output: output}
  def update(stats, message: message), do: %{stats | message: message}
end
