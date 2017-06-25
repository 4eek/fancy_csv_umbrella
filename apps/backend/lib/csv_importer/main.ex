defmodule CsvImporter.Main do
  def import_file(input_file_handler, output_file_handler) do
    alias CsvImporter.{CsvRecordStream, CsvImporter, ErrorCsvBuilder}

    ErrorCsvBuilder.write_header(output_file_handler)

    input_file_handler
    |> CsvRecordStream.create
    |> extract_ok_result
    |> CsvImporter.call
    |> Stream.map(&ErrorCsvBuilder.write_line(&1, output_file_handler))
    |> Enum.to_list
  end

  defp extract_ok_result({:ok, stream}), do: stream
end
