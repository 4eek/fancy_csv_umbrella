defmodule Backend.OutputCsvTest do
  use ExUnit.Case
  alias Backend.{City, OutputCsv}

  test "creates a new output csv" do
    {:ok, device} = OutputCsv.new("", StringIO)

    assert "name,url,errors\n" = TestHelper.read_stringio(device)
  end

  test "appends an invalid record" do
    {:ok, device} = OutputCsv.new("", StringIO)
    changeset = %City{name: nil, url: "http://invalid.com"} |> City.changeset

    OutputCsv.add_line(device, {:error, changeset})

    expected_contents = """
    name,url,errors
    ,http://invalid.com,name can't be blank
    """

    assert expected_contents == TestHelper.read_stringio(device)
  end

  test "does not append record when it is valid" do
    {:ok, device} = OutputCsv.new("", StringIO)
    changeset = %City{name: "Town", url: "http://town.com"} |> City.changeset

    OutputCsv.add_line(device, {:ok, changeset})

    assert "name,url,errors\n" = TestHelper.read_stringio(device)
  end

  defmodule FakeIO do
    def open("", [:write]), do: {:error, "failed"}
  end

  test "returns an error when can not open device" do
    {:error, reason} = OutputCsv.new("", FakeIO)

    assert "failed" == reason
  end
end
