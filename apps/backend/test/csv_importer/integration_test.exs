defmodule CsvImporter.IntegrationTest do
  use DbCase
  alias CsvImporter.{Main, City, Repo}

  test "creates records from a csv file" do
    {:ok, pid} = StringIO.open """
    name,url
    Natal,http://natal.com
    Madrid,http://madrid.org
    """

    pid |> Main.import_file

    assert [
      %City{name: "Madrid", url: "http://madrid.org"},
      %City{name: "Natal", url: "http://natal.com"}
    ] = (City.ordered |> Repo.all)
  end
end
