defmodule Backend.Csv.ImportOutput do
  @headers "name,url,errors"

  def new(path, file_module \\ File) do
    case file_module.open(path, [:write]) do
      {:ok, device} = value ->
        write device, @headers
        value
      {:error, message} -> {:error, message}
    end
  end

  defp write(device, contents), do: IO.binwrite device, contents <> "\n"

  def add_line(_device, {:ok, _changeset}), do: nil
  def add_line(device, {:error, changeset}), do: write device, to_line(changeset)

  defp to_line(changeset) do
    changeset
    |> get_fields
    |> Enum.join(",")
  end

  defp get_fields(changeset) do
    do_get_fields(changeset, [:name, :url]) ++ [errors(changeset)]
  end

  defp do_get_fields(changeset, fields) do
    for name <- fields, do: Ecto.Changeset.get_field(changeset, name)
  end

  defp errors(%{errors: errors}) do
    errors
    |> Enum.map(&to_messages(&1))
    |> Enum.join(" ")
  end

  defp to_messages({column, {error_message, _}}), do: "#{column} #{error_message}"
end
