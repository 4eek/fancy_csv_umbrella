defmodule Backend.Main do
  alias Backend.{CsvRecordStream, ErrorCsvBuilder, Repo}

  def import_file(input_device, output_device, on_update) do
    ErrorCsvBuilder.write_header(output_device)

    input_device
    |> create_csv_stream
    |> import_records
    |> write_output_csv(output_device)
    |> sum_and_broadcast_stats(on_update)
  end

  defp create_csv_stream(input_device) do
    {:ok, stream } = CsvRecordStream.create(input_device)

    stream
  end

  defp import_records(stream) do
    stream
    |> Task.async_stream(__MODULE__, :import, [], max_concurrency: 10)
    |> Stream.map(fn({:ok, tuple}) -> tuple end)
  end

  def import(record = %module{}) do
    {record |> module.changeset |> Repo.insert, record}
  end

  def write_output_csv(stream, output_device) do
    stream
    |> Stream.map(fn(tuple) ->
      ErrorCsvBuilder.write_line(tuple, output_device)
      tuple
    end)
  end

  def sum_and_broadcast_stats(tuple, on_update) do
    Enum.reduce(tuple, %{ok: 0, error: 0}, &sum_stats(&1, &2, on_update))
  end

  defp sum_stats({{result, _}, _}, stats, on_update) do
    result |> sum_stats(stats) |> on_update.()
  end

  def sum_stats(:ok, stats), do: %{stats | ok: stats.ok + 1}
  def sum_stats(:error, stats), do: %{stats | error: stats.error + 1}
end
