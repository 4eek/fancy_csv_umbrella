defmodule Backend.Csv.RecordStream do
  alias Backend.Csv.Headers
  alias Backend.City
  alias NimbleCSV.RFC4180, as: Parser

  def create(device) when is_pid(device) do
    stream = device |> to_stream
    headers = stream |> extract_headers

    if Headers.valid?(headers) do
      {:ok, Stream.map(stream, &to_struct(&1, headers))}
    else
      :invalid_csv
    end
  end

  defp to_stream(device) do
    device
    |> IO.stream(:line)
    |> Parser.parse_stream(headers: false)
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

