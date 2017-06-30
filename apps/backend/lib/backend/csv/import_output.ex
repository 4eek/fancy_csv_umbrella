defmodule Backend.Csv.ImportOutput do
  alias NimbleCSV.RFC4180, as: Parser
  alias Ecto.Changeset

  def new(path, headers, mod \\ File) do
    case mod.open(path, [:write]) do
      {:ok, device} = tuple ->
        write device, dump_line([headers ++ [:errors]])
        {:ok, {device, headers}}
      {:error, message} -> {:error, message}
    end
  end

  defp write(device, contents), do: IO.binwrite device, contents

  def add_line(_output, {:ok, %{}}), do: nil
  def add_line({device, headers}, {:error, %Changeset{} = changeset}) do
    write device, dump_line(changeset, headers)
  end

  def close({device, _}), do: File.close(device)

  defp dump_line(%Changeset{} = changeset, headers) do
    changeset
    |> extract_columns(headers)
    |> dump_line
  end

  defp dump_line(line), do: Parser.dump_to_iodata line

  defp extract_columns(changeset, headers) do
    [extract_fields(changeset, headers) ++ [extract_errors(changeset)]]
  end

  defp extract_fields(changeset, headers) do
    headers
    |> Enum.map(&Changeset.get_field(changeset, &1))
  end

  defp extract_errors(%{errors: errors}) do
    errors
    |> Enum.map(&format_error(&1))
    |> Enum.join(", ")
  end

  defp format_error({column, {message, _}}), do: "#{column} #{message}"
end
