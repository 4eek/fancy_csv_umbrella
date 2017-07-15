defmodule Csv.ImportTest do
  use ExUnit.Case

  alias Csv
  alias Csv.Mocks.{Record, Repo}
  alias Csv.TestHelpers.Fixture

  setup do
    Repo.start_link

    {:ok, output_path} = Briefly.create
    {:ok, output_path: output_path}
  end

  def assert_file_contents(path, expected_contents) do
    {:ok, contents} = File.read(path)
    assert expected_contents == contents
  end
  
  test "imports records of a csv file", %{output_path: output_path} do
    options = %Csv.Import.Options{
      input_path: Fixture.path("cities.csv"),
      output_path: output_path,
      headers: ~w(name url)a,
      type: Record,
      repo: Repo,
      max_concurrency: 2
    }

    Csv.Import.call options, fn(stats) ->
      send self(), stats
      nil
    end

    assert_file_contents output_path, """
    name,url,errors
    ,http://invalid1.com,name can't be blank
    ,http://invalid2.com,name can't be blank
    """
    assert_receive %{error: 0, ok: 1}
    assert_receive %{error: 2, ok: 4}
    assert [
      %Record{name: "Bar", url: "http://bar.org"},
      %Record{name: "Foo", url: "http://foo.org"},
      %Record{name: "Madrid", url: "http://madrid.org"},
      %Record{name: "Natal", url: "http://natal.com"}
    ] = Repo.all

  end

  test "yields error when csv has invalid headers", %{output_path: output_path} do
    options = %Csv.Import.Options{
      input_path: Fixture.path("invalid_cities.csv"),
      output_path: output_path,
      headers: ~w(name url)a,
      type: Record,
      repo: Repo,
      max_concurrency: 2
    }

    Csv.Import.call options, fn(stats) ->
      send self(), stats
      nil
    end

    assert_file_contents output_path, ""
    assert_receive %{error: 0, ok: 0, message: "Invalid CSV headers"}
    assert [] == Repo.all
  end
end
