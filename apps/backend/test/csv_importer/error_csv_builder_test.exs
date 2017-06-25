defmodule CsvImporter.ErrorsCsvBuilderTest do
  use ExUnit.Case
  alias CsvImporter.{City, ErrorCsvBuilder}
  import TestHelper, only: [read_stringio: 1]

  test "writes the CSV header to a file" do
    {:ok, file_handler} = StringIO.open("")

    ErrorCsvBuilder.write_header(file_handler)

    assert "name,url,errors\n" = read_stringio(file_handler)
  end

  test "appends an invalid record to a file" do
    {:ok, file_handler} = StringIO.open("")
    record = %City{name: nil, url: "http://invalid.com"}
    changeset = City.changeset(record)

    ErrorCsvBuilder.write_line({{:error, changeset}, record}, file_handler)

    assert ",http://invalid.com,name can't be blank\n" = read_stringio(file_handler)
  end

  test "does not append record when it is valid" do
    {:ok, file_handler} = StringIO.open("")
    record = %City{name: "Town", url: "http://town.com"}
    changeset = City.changeset(record)

    ErrorCsvBuilder.write_line({{:ok, changeset}, record}, file_handler)

    assert "" = read_stringio(file_handler)
  end
end
