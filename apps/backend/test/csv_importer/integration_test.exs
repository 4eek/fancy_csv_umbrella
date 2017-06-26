defmodule CsvImporter.IntegrationTest do
  use DbCase
  alias CsvImporter.{Main, City, Repo}
  import TestHelper, only: [read_stringio: 1]

  test "creates records from a csv file" do
    {:ok, input_file_handler} = StringIO.open """
    name,url
    Natal,http://natal.com
    ,http://invalid1.com
    Madrid,http://madrid.org
    ,http://invalid2.com
    """
    {:ok, output_file_handler} = StringIO.open("")

    expected_output = [
      "name,url,errors\n",
      ",http://invalid1.com,name can't be blank\n",
      ",http://invalid2.com,name can't be blank\n"
    ] |> Enum.join

    self = self()

    Main.import_file input_file_handler, output_file_handler, fn(status) ->
      send self, status
    end

    assert [
      %City{name: "Madrid", url: "http://madrid.org"},
      %City{name: "Natal", url: "http://natal.com"}
    ] = (City.ordered |> Repo.all)

    assert expected_output == read_stringio(output_file_handler)
    assert_receive %{error: 0, ok: 1}
    assert_receive %{error: 1, ok: 1}
    assert_receive %{error: 1, ok: 2}
    assert_receive %{error: 2, ok: 2}
  end
end
