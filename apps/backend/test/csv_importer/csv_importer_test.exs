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
    ] = (City.ordered |> Repo.all)
  end

  test "does not create records that are invalid" do
    records = [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: nil, url: "http://invalid.com"},
    ]

    CsvImporter.call(records)

    assert [%City{name: "Madrid", url: "http://madrid.com"}] = (City |> Repo.all)
  end
end
