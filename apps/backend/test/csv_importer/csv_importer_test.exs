defmodule Backend.CsvImporterTest do
  use DbCase
  alias Backend.{CsvImporter, City, Repo}

  test "creates records from a csv file" do
    records = [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"}
    ]

    records |> CsvImporter.call |> Enum.to_list

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

    records |> CsvImporter.call |> Enum.to_list

    assert [%City{name: "Madrid", url: "http://madrid.com"}] = (City |> Repo.all)
  end
end
