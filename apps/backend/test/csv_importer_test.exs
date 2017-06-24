defmodule CsvImporterTest do
  use DbCase
  alias CsvImporter.{City, Repo}

  test "insert a city and query it back" do
    city = %City{name: "My city"} |> Repo.insert!

    found = City.find_by_name("My city") |> Repo.all

    assert Enum.count(found) == 1
    assert List.first(found).id == city.id
  end
end
