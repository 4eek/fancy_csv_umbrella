defmodule CsvImporter.Main do
  def import_file(input_file_handler, output_file_handler, on_update) do
    alias CsvImporter.{CsvRecordStream, CsvImporter, ErrorCsvBuilder}

    ErrorCsvBuilder.write_header(output_file_handler)

    status = %{ok: 0, error: 0}

    input_file_handler
    |> CsvRecordStream.create
    |> extract_ok_result
    |> CsvImporter.call
    |> Stream.map(fn(record) ->
      ErrorCsvBuilder.write_line(record, output_file_handler)
      record
    end)
    |> Enum.reduce(status, fn
      {{:ok, _}, _}, memo ->
        memo = %{memo | ok: memo.ok + 1}
        on_update.(memo)
        memo
      {{:error, _}, _}, memo ->
        memo = %{memo | error: memo.error + 1}
        on_update.(memo)
        memo
    end)
  end

  defp extract_ok_result({:ok, stream}), do: stream
end
