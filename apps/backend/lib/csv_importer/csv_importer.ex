defmodule CsvImporter.CsvImporter do
  alias CsvImporter.{City, Repo}

  def call(file_handler) when is_pid(file_handler) do
    stream = file_handler |> IO.stream(:line)
    headers = stream
    |> Enum.take(1)
    |> List.first
    |> String.strip
    |> String.split(",")
    |> Enum.map(&String.to_atom/1)

    stream
    |> Stream.map(&String.strip/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn(line) -> to_struct(line, headers) end)
    |> Enum.map(&Repo.insert(&1))
  end

  defp to_struct(line, headers) do
    contents = headers
    |> Enum.zip(line)
    |> Enum.into(%{})

    struct(City, contents)
  end
end
