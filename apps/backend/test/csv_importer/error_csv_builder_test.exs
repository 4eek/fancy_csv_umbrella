defmodule CsvImporter.ErrorsCsvBuilderTest do
  use ExUnit.Case
  alias CsvImporter.{City, ErrorCsvBuilder}

  test "writes the CSV header to a file" do
    {:ok, file_handler} = StringIO.open("")

    ErrorCsvBuilder.write_header(file_handler)

    assert {_, "name,url,errors\n"} = StringIO.contents(file_handler)
  end

  test "appends an invalid record to a file" do
    {:ok, file_handler} = StringIO.open("")
    record = %City{name: nil, url: "http://invalid.com"}
    changeset = City.changeset(record)

    ErrorCsvBuilder.write_line({:error, changeset}, record, file_handler)

    assert {_, ",http://invalid.com,name can't be blank\n"} = StringIO.contents(file_handler)
  end
end
