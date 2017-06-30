defmodule Backend.Csv.Import do
  alias Backend.{Csv, SaveRecord}

  @max_concurrency 10

  def call(input_path, output_path, format = %Csv.Format{}, on_update) do
    {:ok, input_device} = File.open(input_path)

    input_device
    |> Csv.RecordStream.new(format)
    |> do_import_file(format, output_path, Csv.Import.Stats.new, on_update)

    File.close input_device
  end

  defp do_import_file({:ok, stream}, format, output_path, stats, on_update) do
    {:ok, output} = Csv.Import.Output.new(output_path, format.headers)

    stream
    |> importable_record_stream
    |> writeable_output_stream(output)
    |> kick_off_and_sum_stats(stats, on_update)

    Csv.Import.Output.close output
  end

  defp do_import_file(:invalid_csv, _, _, stats, on_update) do
    stats
    |> Csv.Import.Stats.update(message: "Invalid CSV headers")
    |> on_update.()
  end

  defp importable_record_stream(stream) do
    stream
    |> Task.async_stream(SaveRecord, :call, [], max_concurrency: @max_concurrency)
    |> Stream.map(fn({:ok, changeset}) -> changeset end)
  end

  defp writeable_output_stream(stream, output) do
    stream
    |> Stream.map(&add_output_row(&1, output))
  end

  defp add_output_row(changeset, output) do
    Csv.Import.Output.add_row output, changeset
    changeset
  end

  defp kick_off_and_sum_stats(changeset, stats, on_update) do
    Enum.reduce(changeset, stats, &sum_stats(&2, &1, on_update))
  end

  defp sum_stats(stats, {result, _}, on_update) do
    new_stats = stats |> Csv.Import.Stats.update(result)
    new_stats |> on_update.()
    new_stats
  end
end
