defmodule CsvImporter.ErrorCsvBuilder do
  def call({:error, _}, record, file_handler) do
    headers = "name,url\n"
    contents = "#{record.name},#{record.url}\n"

    IO.binwrite file_handler, headers <> contents
  end
end
