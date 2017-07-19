defmodule Csv.Import.Stats do
  defmodule State do
    defstruct ok: 0, error: 0, output: nil, message: nil

    def new, do: %__MODULE__{}

    def update(stats, :ok), do: %{stats | ok: stats.ok + 1}
    def update(stats, :error), do: %{stats | error: stats.error + 1}
    def update(stats, output: output), do: %{stats | output: output}
    def update(stats, message: message), do: %{stats | message: message}
  end

  defdelegate new, to: State

  def sum(stats, {changeset_result, _}, on_update, freq: send_frequency) do
    new_stats = stats |> State.update(changeset_result)
    new_stats |> send_stats(stats, on_update, send_frequency)
    new_stats
  end

  defp send_stats(new_stats, %{ok: ok, error: error}, on_update, frequency)
       when rem(ok + error, frequency) == 0, do: new_stats |> on_update.()

  defp send_stats(_new_stats, _stats, _on_update, _send_stats_freq), do: nil

  def finish(stats, on_update, options) do
    stats
    |> State.update(options)
    |> on_update.()
  end
end
