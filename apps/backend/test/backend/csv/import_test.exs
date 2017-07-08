defmodule Backend.Csv.ImportTest do
  use DbCase
  alias Backend.{Csv, City}

  setup do
    {:ok, output_path} = Briefly.create
    format = %Csv.Format{headers: ~w(name url)a, type: City}

    {:ok, output_path: output_path, format: format}
  end
  
  test "imports records of a csv file", %{output_path: output_path, format: format} do
    input_path = Fixture.path("cities.csv")
    expected_output = """
    name,url,errors
    ,http://invalid1.com,name can't be blank
    ,http://invalid2.com,name can't be blank
    """

    Csv.Import.call input_path, output_path, 2, format, fn(stats) ->
      send self(), stats
      nil
    end

    assert [
      %City{name: "Bar", url: "http://bar.org"},
      %City{name: "Foo", url: "http://foo.org"},
      %City{name: "Madrid", url: "http://madrid.org"},
      %City{name: "Natal", url: "http://natal.com"}
    ] = City.all

    assert {:ok, expected_output} == File.read(output_path)
    assert_receive %{error: 0, ok: 1}
    assert_receive %{error: 2, ok: 4}
  end

  test "yields error when csv has invalid headers", %{output_path: output_path, format: format} do
    input_path = Fixture.path("invalid_cities.csv")

    Csv.Import.call input_path, output_path, 10, format, fn(stats) ->
      send self(), stats
    end

    assert [] == City.all
    assert {:ok, ""} == File.read(output_path)
    assert_receive %{error: 0, ok: 0, message: "Invalid CSV headers"}
  end
end
