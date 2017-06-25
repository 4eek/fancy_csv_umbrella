defmodule CsvImporter.ErrorsCsvBuilderTest do
  use ExUnit.Case
  alias CsvImporter.{City, ErrorCsvBuilder}

  defp read_file(handler), do: handler |> StringIO.contents |> contents
  defp contents({_, contents}), do: contents

  test "writes the CSV header to a file" do
    {:ok, file_handler} = StringIO.open("")

    ErrorCsvBuilder.write_header(file_handler)

    assert "name,url,errors\n" = read_file(file_handler)
  end

  test "appends an invalid record to a file" do
    {:ok, file_handler} = StringIO.open("")
    record = %City{name: nil, url: "http://invalid.com"}
    changeset = City.changeset(record)

    ErrorCsvBuilder.write_line({:error, changeset}, record, file_handler)

    assert ",http://invalid.com,name can't be blank\n" = read_file(file_handler)
  end
end
