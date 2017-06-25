defmodule CsvImporter.ErrorsCsvBuilderTest do
  use ExUnit.Case
  alias CsvImporter.{City, ErrorCsvBuilder}

  test "appends invalid records to a file" do
    {:ok, file_handler} = StringIO.open("")
    record = %City{name: nil, url: "http://invalid.com"}
    changeset = %Ecto.Changeset{}

    ErrorCsvBuilder.call({:error, changeset}, record, file_handler)

    assert {_, "name,url\n,http://invalid.com\n"} = StringIO.contents(file_handler)
  end
end
