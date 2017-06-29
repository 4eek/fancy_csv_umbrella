defmodule Backend.Main do
  alias Backend.{CsvRecordStream, OutputCsv, ImportStats, Repo}

  def import_file(input_path, output_path, on_update) do
    {:ok, input_device} = File.open(input_path)

    input_device
    |> CsvRecordStream.create
    |> do_import_file(output_path, ImportStats.new, on_update)

    File.close input_device
  end

  defp do_import_file({:ok, stream}, output_path, stats, on_update) do
    {:ok, output_path} = OutputCsv.new(output_path)

    stream
    |> importable_record_stream
    |> writeable_output_stream(output_path)
    |> trigger_and_sum_stats(stats, on_update)

    File.close output_path
  end

  defp do_import_file(:invalid_csv, _, stats, on_update) do
    stats
    |> ImportStats.update(message: "Invalid CSV headers")
    |> on_update.()
  end

  defp importable_record_stream(stream) do
    stream
    |> Task.async_stream(__MODULE__, :import_record, [], max_concurrency: 10)
    |> Stream.map(fn({:ok, changeset}) -> changeset end)
  end

  def import_record(record = %module{}) do
    record
    |> module.changeset
    |> Repo.insert
  end

  def writeable_output_stream(stream, output_device) do
    stream
    |> Stream.map(&add_output_line(&1, output_device))
  end

  def add_output_line(changeset, output_device) do
    OutputCsv.add_line output_device, changeset
    changeset
  end

  def trigger_and_sum_stats(changeset, stats, on_update) do
    Enum.reduce(changeset, stats, &sum_stats(&2, &1, on_update))
  end

  defp sum_stats(stats, {result, _}, on_update) do
    stats
    |> ImportStats.update(result)
    |> on_update.()
  end
end
