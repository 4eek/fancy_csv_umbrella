defmodule CsvImporter.CsvImporterTest do
  use DbCase
  alias CsvImporter.{City, CsvImporter}

  test "does not import when csv has no data lines" do
    {:ok, file_handler} = StringIO.open("name,url\n")

    assert :ok == CsvImporter.call(file_handler)
    assert [] == (City |> Repo.all)
  end

  test "imports records from a csv file" do
    {:ok, file_handler} = StringIO.open """
    name,url
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    New York,http://newyork.org
    """

    assert :ok = CsvImporter.call(file_handler)
    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = (City |> Repo.all)
  end

  test "imports successfully when header fields are switched out" do
    {:ok, file_handler} = StringIO.open """
    url,name
    http://madrid.com,Madrid
    http://natal.com.br,Natal
    http://newyork.org,New York
    """

    assert :ok = CsvImporter.call(file_handler)
    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = (City |> Repo.all)
  end

  test "returns invalid_csv when one of the columns is missing" do
    {:ok, file_handler} = StringIO.open """
    name
    Madrid
    Natal
    """

    assert :invalid_csv == CsvImporter.call(file_handler)
  end

  test "returns invalid_csv when one of the columns has wrong name" do
    {:ok, file_handler} = StringIO.open """
    name,urls
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    """

    assert :invalid_csv == CsvImporter.call(file_handler)
  end
end
