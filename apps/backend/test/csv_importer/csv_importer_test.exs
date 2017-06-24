defmodule CsvImporter.CsvImporterTest do
  use DbCase
  alias CsvImporter.{CsvImporter, City, Repo}

  test "creates records from a csv file" do
    records = [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"}
    ]

    CsvImporter.call(records)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"}
    ] = (City |> Repo.all)
  end
end
