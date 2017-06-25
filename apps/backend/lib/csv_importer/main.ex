defmodule CsvImporter.Main do
  def import_file(file_handler) do
    alias CsvImporter.{CsvRecordStream, CsvImporter}

    file_handler
    |> CsvRecordStream.create
    |> extract_ok_result
    |> CsvImporter.call
    |> Enum.to_list
  end

  defp extract_ok_result({:ok, stream}), do: stream
end
