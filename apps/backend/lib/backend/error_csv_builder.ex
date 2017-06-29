defmodule Backend.ErrorCsvBuilder do
  @headers "name,url,errors\n"

  def new(path, file_module \\ File) do
    {:ok, device} = file_module.open(path, [:write])
    IO.binwrite device, @headers

    {:ok, device}
  end

  def write_line(device, {{:error, changeset}, record}) do
    contents = "#{record.name},#{record.url},#{collect_errors(changeset)}\n"

    IO.binwrite device, contents
  end

  def write_line(_, {{:ok, _}, _}), do: nil

  defp collect_errors(%{errors: errors}) do
    errors
    |> Enum.map(&assemble_error(&1))
    |> Enum.join(" ")
  end

  defp assemble_error({column, {desc, _}}), do: "#{column} #{desc}"
end
