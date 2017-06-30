defmodule Backend.Csv.ImportOutputTest do
  use ExUnit.Case
  alias Backend.{City, Csv} 

  @headers ~w(name url)a

  defp read_device({device, _}), do: TestHelper.read_stringio(device)

  test "creates a new output csv" do
    {:ok, state} = Csv.ImportOutput.new("", @headers, StringIO)

    assert "name,url,errors\n" = read_device(state)
  end

  test "appends an invalid record to the output file" do
    {:ok, state} = Csv.ImportOutput.new("", @headers, StringIO)
    changeset = %City{name: nil, url: "http://invalid.com"} |> City.changeset
    expected_contents = """
    name,url,errors
    ,http://invalid.com,name can't be blank
    """

    Csv.ImportOutput.add_row(state, {:error, changeset})

    assert expected_contents == read_device(state)
  end

  test "appends correctly when has more than one validation error" do
    {:ok, state} = Csv.ImportOutput.new("", @headers, StringIO)
    changeset = %City{name: nil, url: nil} |> City.changeset
    expected_contents = """
    name,url,errors
    ,,"name can't be blank, url can't be blank"
    """

    Csv.ImportOutput.add_row(state, {:error, changeset})

    assert expected_contents == read_device(state)
  end

  test "does not append to output file when record is valid" do
    {:ok, state} = Csv.ImportOutput.new("", @headers, StringIO)
    changeset = %City{name: "Town", url: "http://town.com"} |> City.changeset

    Csv.ImportOutput.add_row(state, {:ok, changeset})

    assert "name,url,errors\n" = read_device(state)
  end

  defmodule FakeIO do
    def open("", [:write]), do: {:error, "failed"}
  end

  test "returns an error when can not open device" do
    {:error, reason} = Csv.ImportOutput.new("", @headers, FakeIO)

    assert "failed" == reason
  end
end
