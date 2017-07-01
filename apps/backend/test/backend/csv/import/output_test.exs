defmodule Backend.Csv.Import.OutputTest do
  use ExUnit.Case
  alias Backend.{City, Csv} 

  def changeset(map), do: struct(City, map) |> City.changeset
  def contents({:ok, {_, contents}}), do: contents

  test "creates a new output csv" do
    output = Csv.Import.Output.open("", ~w(name url)a, fn(_) ->
      nil
    end, StringIO)

    assert "name,url,errors\n" == contents(output)
  end

  test "appends an invalid csv row to an output file" do
    output = Csv.Import.Output.open("", ~w(name url)a, fn(output_state) ->
      changeset = changeset(%{name: nil, url: "http://i.com"})
      Csv.Import.Output.add_row output_state, {:error, changeset}
    end, StringIO)
    
    assert """
    name,url,errors
    ,http://i.com,name can't be blank
    """ == contents(output)
  end

  test "writes changeset fields in the output file by header order" do
    output = Csv.Import.Output.open("", ~w(url name)a, fn(output_state) ->
      changeset = changeset(%{name: nil, url: "http://i.com"})
      Csv.Import.Output.add_row output_state, {:error, changeset}
    end, StringIO)

    assert """
    url,name,errors
    http://i.com,,name can't be blank
    """ == contents(output)
  end

  test "appends validation errors to output file correctly" do
    output = Csv.Import.Output.open("", ~w(name url)a, fn(output_state) ->
      changeset = changeset(%{name: nil, url: nil})
      Csv.Import.Output.add_row output_state, {:error, changeset}
    end, StringIO)

    assert """
    name,url,errors
    ,,"name can't be blank, url can't be blank"
    """ == contents(output)
  end

  test "does not append a row to output file when changeset is valid" do
    output = Csv.Import.Output.open("", ~w(name url)a, fn(output_state) ->
      changeset = changeset(%{name: "Town", url: "http://town.com"})
      Csv.Import.Output.add_row output_state, {:ok, changeset}
    end, StringIO)

    assert "name,url,errors\n" = contents(output)
  end

  defmodule FakeIO do
    def open("", [:write]), do: {:error, "failed"}
  end

  test "returns an error when can not open device" do
    output = Csv.Import.Output.open("", ~w(name url)a, fn(_) ->
      nil
    end, FakeIO)

    assert {:error, "failed"} = output
  end
end
