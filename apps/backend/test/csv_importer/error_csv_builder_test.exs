defmodule CsvImporter.ErrorsCsvBuilderTest do
  use ExUnit.Case
  alias CsvImporter.{City, ErrorCsvBuilder}

  test "appends invalid records to a file" do
    {:ok, file_handler} = StringIO.open("")
    record = %City{name: nil, url: "http://invalid.com"}
    changeset = City.changeset(record)

    ErrorCsvBuilder.call({:error, changeset}, record, file_handler)

    assert {_, "name,url,errors\n,http://invalid.com,name can't be blank\n"} = StringIO.contents(file_handler)
  end
end
