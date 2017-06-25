defmodule CsvImporter.CsvImporter do
  alias CsvImporter.Repo

  def call(records) do
    records
    |> Task.async_stream(Repo, :insert, [], max_concurrency: 10)
    |> Enum.to_list
  end
end
