defmodule CsvImporter.CsvImporter do
  defmodule CsvRecordStream do
    alias CsvImporter.{City, Repo}

    @headers ~w(name url)a

    def create(file_handler) when is_pid(file_handler) do
      stream = file_handler |> to_stream
      headers = stream |> extract_headers

      if valid?(headers) do
        stream = stream
        |> Stream.map(&to_struct(&1, headers))
        |> Enum.map(&Repo.insert(&1))

        {:ok, stream}
      else
        :invalid_csv
      end
    end

    defp valid?(headers) do
      Enum.count(headers) == Enum.count(@headers) &&
      Enum.sort(headers) == Enum.sort(@headers)
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

  def call(file_handler) when is_pid(file_handler) do
    case CsvRecordStream.create(file_handler) do
      {:ok, _stream} ->
        :ok
      error -> error
    end
  end
end
