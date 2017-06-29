defmodule Backend.OutputCsvTest do
  use ExUnit.Case
  alias Backend.{City, OutputCsv}
  import TestHelper, only: [read_stringio: 1]

  setup do
    {:ok, device} = OutputCsv.new("", StringIO)
    {:ok, device: device}
  end

  test "creates a new output csv", %{device: device} do
    assert "name,url,errors\n" = read_stringio(device)
  end

  test "appends an invalid record", %{device: device} do
    record = %City{name: nil, url: "http://invalid.com"}
    changeset = City.changeset(record)

    OutputCsv.write_line(device, {{:error, changeset}, record})

    expected_contents = """
    name,url,errors
    ,http://invalid.com,name can't be blank
    """

    assert expected_contents == read_stringio(device)
  end

  test "does not append record when it is valid", %{device: device} do
    record = %City{name: "Town", url: "http://town.com"}
    changeset = City.changeset(record)

    OutputCsv.write_line(device, {{:ok, changeset}, record})

    assert "name,url,errors\n" = read_stringio(device)
  end
end
