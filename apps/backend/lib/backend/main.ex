defmodule Backend.Main do
  alias Backend.{CsvRecordStream, OutputCsv, Repo}

  @stats %{ok: 0, error: 0}

  def import_file(input_path, output_path, on_update) do
    {:ok, input_device} = File.open(input_path)
    {:ok, output_device} = OutputCsv.new(output_path)

    input_device
    |> csv_stream
    |> importable_record_stream
    |> writeable_output_stream(output_device)
    |> trigger_and_sum_stats(on_update)

    File.close input_device
    File.close output_device
  end

  defp csv_stream(input_device) do
    {:ok, stream} = CsvRecordStream.create(input_device)

    stream
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

  def trigger_and_sum_stats(changeset, on_update) do
    Enum.reduce(changeset, @stats, &sum_stats(&1, &2, on_update))
  end

  defp sum_stats({result, _}, stats, on_update) do
    result
    |> sum_stats(stats)
    |> on_update.()
  end

  def sum_stats(:ok, stats), do: %{stats | ok: stats.ok + 1}
  def sum_stats(:error, stats), do: %{stats | error: stats.error + 1}
end
