defmodule Backend.ErrorsCsvBuilderTest do
  use ExUnit.Case
  alias Backend.{City, ErrorCsvBuilder}
  import TestHelper, only: [read_stringio: 1]

  test "creates a new output csv" do
    {:ok, device} = ErrorCsvBuilder.new("", StringIO)

    assert "name,url,errors\n" = read_stringio(device)
  end

  test "appends an invalid record" do
    {:ok, device} = ErrorCsvBuilder.new("", StringIO)

    record = %City{name: nil, url: "http://invalid.com"}
    changeset = City.changeset(record)

    ErrorCsvBuilder.write_line(device, {{:error, changeset}, record})

    expected_contents = """
    name,url,errors
    ,http://invalid.com,name can't be blank
    """

    assert expected_contents == read_stringio(device)
  end

  test "does not append record when it is valid" do
    {:ok, device} = ErrorCsvBuilder.new("", StringIO)

    record = %City{name: "Town", url: "http://town.com"}
    changeset = City.changeset(record)

    ErrorCsvBuilder.write_line(device, {{:ok, changeset}, record})

    assert "name,url,errors\n" = read_stringio(device)
  end
end
