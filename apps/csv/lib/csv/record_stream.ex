defmodule Csv.RecordStream do
  def new(device, headers: valid_headers, type: type) do
    stream = device |> to_stream
    headers = stream |> extract_headers

    if valid_headers?(headers, valid_headers) do
      {:ok, Stream.map(stream, &to_struct(&1, type, headers))}
    else
      :invalid_csv
    end
  end

  def valid_headers?(headers, valid_headers) do
    Enum.sort(headers) == Enum.sort(valid_headers)
  end

  defp to_stream(device) do
    device
    |> IO.stream(:line)
    |> Csv.Parser.parse_stream(headers: false)
  end

  defp extract_headers(stream) do
    stream
    |> Enum.fetch!(0)
    |> Enum.map(&String.to_atom/1)
  end

  defp to_struct(row, type, headers) do
    headers
    |> Enum.zip(row)
    |> Enum.into(%{})
    |> (fn(contents) -> struct(type, contents) end).()
  end
end

