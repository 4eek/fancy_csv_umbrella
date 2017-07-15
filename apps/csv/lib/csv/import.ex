defmodule Csv.Import do
  def call(%Csv.Import.Options{input_path: input_path, type: type} = options, on_update) do
    {:ok, _} = File.open input_path, fn(input_device) ->
      case Csv.RecordStream.new(input_device, headers: options.headers, type: type) do
        {:ok, stream} -> import stream, options, on_update
        :invalid_csv -> abort "Invalid CSV headers", on_update
      end
    end
  end

  defp import(stream, options, on_update) do
    {:ok, _} = Csv.Import.Output.open options.output_path, options.headers, fn(output_state) ->
      stream
      |> Task.async_stream(options.repo, :call, [], max_concurrency: options.max_concurrency)
      |> Stream.map(fn({:ok, changeset}) -> changeset end)
      |> Stream.map(&add_output_row(&1, output_state))
      |> Enum.reduce(Csv.Import.Stats.new, &sum_stats(&2, &1, on_update, options.max_concurrency))
      |> Csv.Import.Stats.update(output: options.output_path)
      |> on_update.()
    end
  end

  defp abort(message, on_update) do
    Csv.Import.Stats.new
    |> Csv.Import.Stats.update(message: message)
    |> on_update.()
  end

  defp add_output_row(changeset, output_state) do
    Csv.Import.Output.add_row output_state, changeset
    changeset
  end

  defp sum_stats(stats, {result, _}, on_update, send_stats_freq) do
    new_stats = stats |> Csv.Import.Stats.update(result)
    new_stats |> send_stats(stats, on_update, send_stats_freq)
    new_stats
  end

  def send_stats(new_stats, %{ok: ok, error: error}, on_update, send_stats_freq)
      when rem(ok + error, send_stats_freq) == 0, do: new_stats |> on_update.()

  def send_stats(_new_stats, _stats, _on_update, _send_stats_freq), do: nil
end
