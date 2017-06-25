defmodule CsvImporter.CsvImporter do
  alias CsvImporter.Repo

  def call(records) do
    records
    |> Task.async_stream(__MODULE__, :insert_record, [], max_concurrency: 10)
    |> Stream.map(fn({:ok, result}) -> result end)
  end

  def insert_record(%module{} = record) do
    {do_insert_record(record, module), record}
  end

  def do_insert_record(record, module) do
    record
    |> module.changeset
    |> Repo.insert
  end
end
