defmodule CsvImporter.CsvImporter do
  alias CsvImporter.Repo

  def call(records) do
    records
    |> Enum.map(&Repo.insert(&1))
  end
end
