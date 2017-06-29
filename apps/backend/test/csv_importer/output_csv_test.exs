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
    changeset = %City{name: nil, url: "http://invalid.com"} |> City.changeset

    OutputCsv.add_line(device, {:error, changeset})

    expected_contents = """
    name,url,errors
    ,http://invalid.com,name can't be blank
    """

    assert expected_contents == read_stringio(device)
  end

  test "does not append record when it is valid", %{device: device} do
    changeset = %City{name: "Town", url: "http://town.com"} |> City.changeset

    OutputCsv.add_line(device, {:ok, changeset})

    assert "name,url,errors\n" = read_stringio(device)
  end
end
