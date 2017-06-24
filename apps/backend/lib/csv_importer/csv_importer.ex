defmodule CsvImporter.CsvImporter do
  alias CsvImporter.{City, Repo}

  def call(file_handler) when is_pid(file_handler) do
    stream = file_handler |> to_stream
    headers = stream |> extract_headers

    stream
    |> Stream.map(&to_struct(&1, headers))
    |> Enum.map(&Repo.insert(&1))
  end

  defp to_stream(file_handler) do
    file_handler
    |> IO.stream(:line)
    |> Stream.map(&String.strip/1)
    |> Stream.map(&String.split(&1, ","))
  end

  defp extract_headers(stream) do
    stream
    |> Enum.fetch!(0)
    |> Enum.map(&String.to_atom/1)
  end

  defp to_struct(line, headers) do
    headers
    |> Enum.zip(line)
    |> Enum.into(%{})
    |> (fn(contents) -> struct(City, contents) end).()
  end
end
