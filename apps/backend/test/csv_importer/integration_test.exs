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

    Main.import_file(input_file_handler, output_file_handler)

    assert [
      %City{name: "Madrid", url: "http://madrid.org"},
      %City{name: "Natal", url: "http://natal.com"}
    ] = (City.ordered |> Repo.all)

    assert expected_output == read_stringio(output_file_handler)
  end
end
