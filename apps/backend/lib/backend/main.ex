defmodule Backend.Main do
  alias Backend.{CsvRecordStream, CsvImporter, ErrorCsvBuilder}

  def import_file(input_file_handler, output_file_handler, on_update) do
    ErrorCsvBuilder.write_header(output_file_handler)

    status = %{ok: 0, error: 0}

    input_file_handler
    |> CsvRecordStream.create
    |> extract_ok_result
    |> CsvImporter.call
    |> Stream.map(&write_output_line(&1, output_file_handler))
    |> Enum.reduce(status, &sum_result(&1, &2, on_update))
  end

  defp write_output_line(record, output_file_handler) do
    record
    |> ErrorCsvBuilder.write_line(output_file_handler)
    |> (fn(_) -> record end).()
  end

  defp sum_result({{status, _}, _}, memo, callback) do
    memo = status |> do_sum_result(memo)
    callback.(memo)
    memo
  end

  def do_sum_result(:ok, memo), do: %{memo | ok: memo.ok + 1}
  def do_sum_result(:error, memo), do: %{memo | error: memo.error + 1}

  defp extract_ok_result({:ok, stream}), do: stream
end
