defmodule Backend.Csv.Import.OutputTest do
  use ExUnit.Case
  alias Backend.{City, Csv} 

  def changeset(map), do: struct(City, map) |> City.changeset
  def assert_device_closes(device), do: assert_receive {:closed_mock, ^device}
  def assert_file_contents(device, expected_contents) do
    {:ok, {_, contents}} = StringIO.close(device)
    assert expected_contents == contents
  end

  defmodule GoodIO do
    def open(device, [:write]), do: {:ok, device}
    def close(device), do: send(self(), {:closed_mock, device})
  end

  test "creates a new output csv with just the given headers" do
    {:ok, device} = StringIO.open("")

    Csv.Import.Output.open(device, ~w(name url)a, fn(_) -> nil end, GoodIO)

    assert_file_contents device, "name,url,errors\n"
  end

  test "appends an invalid csv row after the headers" do
    {:ok, device} = StringIO.open("")

    Csv.Import.Output.open(device, ~w(name url)a, fn(output_state) ->
      Csv.Import.Output.add_row output_state, {:error, changeset(%{
        name: nil,
        url: "http://i.com"
      })}
    end, GoodIO)

    assert_file_contents device, """
    name,url,errors
    ,http://i.com,name can't be blank
    """
  end

  test "considers given header order when writing invalid csv row" do
    {:ok, device} = StringIO.open("")

    Csv.Import.Output.open(device, ~w(url name)a, fn(output_state) ->
      Csv.Import.Output.add_row output_state, {:error, changeset(%{
        name: nil,
        url: "http://i.com"
      })}
    end, GoodIO)

    assert_file_contents device, """
    url,name,errors
    http://i.com,,name can't be blank
    """
    assert_device_closes device
  end

  test "gathers validation errors correctly" do
    {:ok, device} = StringIO.open("")

    Csv.Import.Output.open(device, ~w(name url)a, fn(output_state) ->
      Csv.Import.Output.add_row output_state, {:error, changeset(%{
        name: nil,
        url: nil
      })}
    end, GoodIO)

    assert_file_contents device, """
    name,url,errors
    ,,"name can't be blank, url can't be blank"
    """
    assert_device_closes device
  end

  test "does not append valid changeset fields" do
    {:ok, device} = StringIO.open("")

    Csv.Import.Output.open(device, ~w(name url)a, fn(output_state) ->
      Csv.Import.Output.add_row output_state, {:ok, changeset(%{
        name: "Town",
        url: "http://town.com"
      })}
    end, GoodIO)

    assert_file_contents device, "name,url,errors\n"
    assert_device_closes device
  end

  defmodule BadIO do
    def open("path.csv", [:write]), do: {:error, "failed"}
  end

  test "returns an error when open method returns error" do
    output = Csv.Import.Output.open "path.csv", ~w(name url)a, fn(_) ->
      nil
    end, BadIO

    assert {:error, "failed"} = output
  end
end
