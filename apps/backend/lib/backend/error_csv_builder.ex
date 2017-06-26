defmodule Backend.ErrorCsvBuilder do
  def write_header(file_handler) do
    IO.binwrite file_handler, "name,url,errors\n"
  end

  def write_line({{:error, changeset}, record}, file_handler) do
    contents = "#{record.name},#{record.url},#{collect_errors(changeset)}\n"

    IO.binwrite file_handler, contents
  end

  def write_line({{:ok, _}, _}, _), do: nil

  defp collect_errors(%{errors: errors}) do
    errors
    |> Enum.map(&assemble_error(&1))
    |> Enum.join(" ")
  end

  defp assemble_error({column, {desc, _}}), do: "#{column} #{desc}"
end
