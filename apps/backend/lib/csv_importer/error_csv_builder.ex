defmodule CsvImporter.ErrorCsvBuilder do
  def call({:error, changeset}, record, file_handler) do
    headers = "name,url,errors\n"
    contents = "#{record.name},#{record.url},#{collect_errors(changeset)}\n"

    IO.binwrite file_handler, headers <> contents
  end

  defp collect_errors(%{errors: errors}) do
    errors
    |> Enum.map(fn({column, {desc, _}}) -> "#{column} #{desc}" end)
    |> Enum.join
  end
end
