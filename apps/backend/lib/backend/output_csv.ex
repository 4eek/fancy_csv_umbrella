defmodule Backend.OutputCsv do
  @headers "name,url,errors"

  def new(path, file_module \\ File) do
    case file_module.open(path, [:write]) do
      {:ok, device} = value ->
        write device, @headers
        value
      other -> other
    end
  end

  defp write(device, contents), do: device |> IO.binwrite(contents <> "\n")

  def add_line(_device, {:ok, _changeset}), do: nil
  def add_line(device, {:error, changeset}), do: write device, to_line(changeset)

  defp to_line(changeset) do
    (fetch_fields(changeset, [:name, :url]) ++ [errors(changeset)])
    |> Enum.join(",")
  end

  defp fetch_fields(changeset, fields) do
    for name <- fields do
      {_, value} = changeset |> Ecto.Changeset.fetch_field(name)
      value
    end
  end

  defp errors(%{errors: errors}) do
    errors |> Enum.map(&to_messages(&1)) |> Enum.join(" ")
  end

  defp to_messages({column, {desc, _}}), do: "#{column} #{desc}"
end
