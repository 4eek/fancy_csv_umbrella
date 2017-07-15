defmodule Csv.Import.Output do
  alias Ecto.Changeset

  def open(path, headers, callback, mod \\ File) do
    case mod.open(path, [:write]) do
      {:ok, device} ->
        try do
          write device, dump_row([headers ++ [:errors]])
          {:ok, callback.({device, headers, mod})}
        after
          mod.close(device)
        end
      {:error, message} -> {:error, message}
    end
  end

  defp write(device, contents), do: IO.binwrite device, contents

  def add_row(_output, {:ok, %{}}), do: nil
  def add_row({device, headers, _}, {:error, %Changeset{} = changeset}) do
    write device, dump_row(changeset, headers)
  end

  defp dump_row(%Changeset{} = changeset, headers) do
    changeset
    |> extract_columns(headers)
    |> dump_row
  end

  defp dump_row(row), do: Csv.Parser.dump_to_iodata row

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
