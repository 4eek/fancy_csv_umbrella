defmodule Backend.Csv.ImportOutput do
  alias NimbleCSV.RFC4180, as: Parser
  alias Ecto.Changeset

  @headers ~w(name url)a

  def new(path, mod \\ File) do
    case mod.open(path, [:write]) do
      {:ok, device} = tuple ->
        write device, dump_line([@headers ++ [:errors]])
        tuple
      {:error, message} -> {:error, message}
    end
  end

  defp write(device, contents), do: IO.binwrite device, contents

  def add_line(_device, {:ok, %{}}), do: nil
  def add_line(device, {:error, %Changeset{} = changeset}) do
    write device, dump_line(changeset)
  end

  defp dump_line(%Changeset{} = changeset) do
    changeset
    |> extract_columns
    |> dump_line
  end

  defp dump_line(line), do: Parser.dump_to_iodata line

  defp extract_columns(changeset) do
    [extract_fields(changeset) ++ [extract_errors(changeset)]]
  end

  defp extract_fields(changeset) do
    @headers
    |> Enum.map(&Changeset.get_field(changeset, &1))
  end

  defp extract_errors(%{errors: errors}) do
    errors
    |> Enum.map(&format_error(&1))
    |> Enum.join(", ")
  end

  defp format_error({column, {message, _}}), do: "#{column} #{message}"
end
