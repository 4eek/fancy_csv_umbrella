defmodule CsvImporter.ErrorCsvBuilder do
  def call({:error, changeset}, record, file_handler) do
    headers = "name,url,errors\n"
    contents = "#{record.name},#{record.url},#{collect_errors(changeset)}\n"

    IO.binwrite file_handler, headers <> contents
  end

  defp collect_errors(%{errors: errors}) do
    errors
    |> Enum.map(&assemble_error(&1))
    |> Enum.join
  end

  defp assemble_error({column, {desc, _}}), do: "#{column} #{desc}"
end
