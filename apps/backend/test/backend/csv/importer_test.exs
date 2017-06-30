defmodule Backend.Csv.ImporterTest do
  use DbCase
  alias Backend.Csv
  alias Backend.{City, Repo}

  setup do
    {:ok, output_path} = Briefly.create
    csv_definition = %Csv.Format{headers: ~w(name url)a, type: City}

    {:ok, output_path: output_path, format: csv_definition}
  end

  test "creates records from a csv file", %{output_path: output_path, format: format} do
    input_path = Fixture.path("cities.csv")

    Csv.Importer.call input_path, output_path, format, fn(stats) ->
      send self(), stats
    end

    expected_output = """
    name,url,errors
    ,http://invalid1.com,name can't be blank
    ,http://invalid2.com,name can't be blank
    """

    {:ok, output} = File.read(output_path)

    assert [
      %City{name: "Madrid", url: "http://madrid.org"},
      %City{name: "Natal", url: "http://natal.com"}
    ] = (City.ordered |> Repo.all)

    assert expected_output == output
    assert_receive %{error: 0, ok: 1}
    assert_receive %{error: 1, ok: 1}
    assert_receive %{error: 1, ok: 2}
    assert_receive %{error: 2, ok: 2}
  end

  test "yields error when csv has invalid headers", %{output_path: output_path, format: format} do
    input_path = Fixture.path("invalid_cities.csv")

    Csv.Importer.call input_path, output_path, format, fn(stats) ->
      send self(), stats
    end

    assert [] == City.ordered |> Repo.all
    assert_receive %{error: 0, ok: 0, message: "Invalid CSV headers"}
  end
end
