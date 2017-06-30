defmodule Backend.Csv.ImportOutputTest do
  use ExUnit.Case
  alias Backend.City 
  alias Backend.Csv.ImportOutput

  @headers ~w(name url)a

  defp read_device({device, _}), do: TestHelper.read_stringio(device)

  test "creates a new output csv" do
    {:ok, output} = ImportOutput.new("", @headers, StringIO)

    assert "name,url,errors\n" = read_device(output)
  end

  test "appends an invalid record to the output file" do
    {:ok, output} = ImportOutput.new("", @headers, StringIO)
    changeset = %City{name: nil, url: "http://invalid.com"} |> City.changeset

    ImportOutput.add_line(output, {:error, changeset})

    expected_contents = """
    name,url,errors
    ,http://invalid.com,name can't be blank
    """

    assert expected_contents == read_device(output)
  end

  test "appends correctly when more than one validation error" do
    {:ok, output} = ImportOutput.new("", @headers, StringIO)
    changeset = %City{name: nil, url: nil} |> City.changeset

    ImportOutput.add_line(output, {:error, changeset})

    expected_contents = """
    name,url,errors
    ,,"name can't be blank, url can't be blank"
    """

    assert expected_contents == read_device(output)
  end

  test "does not append to output file when record is valid" do
    {:ok, output} = ImportOutput.new("", @headers, StringIO)
    changeset = %City{name: "Town", url: "http://town.com"} |> City.changeset

    ImportOutput.add_line(output, {:ok, changeset})

    assert "name,url,errors\n" = read_device(output)
  end

  defmodule FakeIO do
    def open("", [:write]), do: {:error, "failed"}
  end

  test "returns an error when can not open device" do
    {:error, reason} = ImportOutput.new("", @headers, FakeIO)

    assert "failed" == reason
  end
end
