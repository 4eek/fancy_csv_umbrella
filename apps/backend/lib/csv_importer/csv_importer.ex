defmodule CsvImporter.CsvImporter do
  alias CsvImporter.Repo

  def call(records) do
    records
    |> Task.async_stream(__MODULE__, :insert_record, [], max_concurrency: 10)
  end

  def insert_record(%module{} = record) do
    record
    |> module.changeset
    |> Repo.insert
  end
end
