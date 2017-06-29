defmodule Backend.IntegrationTest do
  use DbCase
  alias Backend.{Main, City, Repo}

  test "creates records from a csv file" do
    input_path = Fixture.path("cities.csv")
    {:ok, output_path} = Briefly.create

    Main.import_file input_path, output_path, fn(status) ->
      send self(), status
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
end
