defmodule CsvImporter.CsvImporter do
  alias CsvImporter.{CsvRecordStream, Repo}

  def call(file_handler) when is_pid(file_handler) do
    case CsvRecordStream.create(file_handler) do
      {:ok, stream} ->
        stream |> Enum.map(&Repo.insert(&1))
        :ok
      error -> error
    end
  end
end
