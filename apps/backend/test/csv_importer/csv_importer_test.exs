defmodule CsvImporter.CsvImporterTest do
  use DbCase
  alias CsvImporter.{CsvImporter, City, Repo}

  test "creates records from a csv file" do
    {:ok, file_handler} = StringIO.open """
    name,url
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    New York,http://newyork.org
    """

    :ok = CsvImporter.call(file_handler)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = (City |> Repo.all)
  end
end
