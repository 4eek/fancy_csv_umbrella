defmodule Backend.Csv.ImportOutputTest do
  use ExUnit.Case
  alias Backend.City 
  alias Backend.Csv.ImportOutput

  test "creates a new output csv" do
    {:ok, device} = ImportOutput.new("", StringIO)

    assert "name,url,errors\n" = TestHelper.read_stringio(device)
  end

  test "appends an invalid record" do
    {:ok, device} = ImportOutput.new("", StringIO)
    changeset = %City{name: nil, url: "http://invalid.com"} |> City.changeset

    ImportOutput.add_line(device, {:error, changeset})

    expected_contents = """
    name,url,errors
    ,http://invalid.com,name can't be blank
    """

    assert expected_contents == TestHelper.read_stringio(device)
  end

  test "does not append record when it is valid" do
    {:ok, device} = ImportOutput.new("", StringIO)
    changeset = %City{name: "Town", url: "http://town.com"} |> City.changeset

    ImportOutput.add_line(device, {:ok, changeset})

    assert "name,url,errors\n" = TestHelper.read_stringio(device)
  end

  defmodule FakeIO do
    def open("", [:write]), do: {:error, "failed"}
  end

  test "returns an error when can not open device" do
    {:error, reason} = ImportOutput.new("", FakeIO)

    assert "failed" == reason
  end
end
