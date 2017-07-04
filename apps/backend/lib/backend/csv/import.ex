defmodule Backend.Csv.Import do
  alias Backend.{Csv, SaveRecord}

  @max_concurrency 10

  def call(input_path, output_path, format = %Csv.Format{}, on_update) do
    {:ok, _} = File.open input_path, fn(input_device) ->
      case Csv.RecordStream.new(input_device, format) do
        {:ok, stream} -> import(stream, format, output_path, on_update)
        :invalid_csv -> abort(on_update)
      end
    end
  end

  defp import(stream, format, output_path, on_update) do
    {:ok, _} = Csv.Import.Output.open output_path, format.headers, fn(output_state) ->
      stream
      |> importable_record_stream
      |> writeable_output_stream(output_state)
      |> kick_off_and_sum_stats(on_update, output_path)
    end
  end

  defp abort(on_update) do
    Csv.Import.Stats.new
    |> Csv.Import.Stats.update(message: "Invalid CSV headers")
    |> on_update.()
  end

  defp importable_record_stream(stream) do
    stream
    |> Task.async_stream(SaveRecord, :call, [], max_concurrency: @max_concurrency)
    |> Stream.map(fn({:ok, changeset}) -> changeset end)
  end

  defp writeable_output_stream(stream, output_state) do
    stream
    |> Stream.map(&add_output_row(&1, output_state))
  end

  defp add_output_row(changeset, output_state) do
    Csv.Import.Output.add_row output_state, changeset
    changeset
  end

  defp kick_off_and_sum_stats(changeset, on_update, output_path) do
    Enum.reduce(changeset, Csv.Import.Stats.new, &sum_stats(&2, &1, on_update))
    |> Csv.Import.Stats.update(output: output_path)
    |> on_update.()
  end

  defp sum_stats(stats, {result, _}, on_update) do
    new_stats = stats |> Csv.Import.Stats.update(result)
    new_stats |> on_update.()
    new_stats
  end
end
