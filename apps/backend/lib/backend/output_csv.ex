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

  def write_line(device, {{:error, changeset}, record}) do
    line = changeset |> assemble_line(record)
    device |> write(line)
  end

  def write_line(_device, {{:ok, _changeset}, _record}), do: nil

  def assemble_line(changeset, %{name: name, url: url}) do
    [name, url, errors(changeset)] |> Enum.join(",")
  end

  defp errors(%{errors: errors}) do
    errors |> Enum.map(&assemble_error(&1)) |> Enum.join(" ")
  end

  defp assemble_error({column, {desc, _}}), do: "#{column} #{desc}"
end
