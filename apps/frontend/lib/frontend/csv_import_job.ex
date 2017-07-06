defmodule Frontend.CityCsvJob do
  alias Frontend.{BackgroundJob, Endpoint, ImportPath}
  alias Backend.{Csv, City}

  @upload_base "priv/static"
  @format %Csv.Format{headers: ~w(name url)a, type: City}

  def enqueue(%Plug.Upload{path: source_path, filename: filename}) do
    {input_path, output_path} = ImportPath.resolve(@upload_base, filename)

    File.mkdir_p Path.dirname(input_path)
    File.cp source_path, input_path

    add_job filename, input_path, output_path
  end

  defp add_job(filename, input_path, output_path) do
    BackgroundJob.add fn %{id: id} ->
      BackgroundJob.update %{id: id, filename: filename}
      Csv.Import.call input_path, output_path, @format, &broadcast(id, &1)
    end
  end

  defp broadcast(id, status) do
    data = status |> Map.merge(%{id: id}) |> filter

    BackgroundJob.update data
    Endpoint.broadcast("city_import:status", "change", data)
  end

  defp filter(%{output: @upload_base <> output} = data), do: %{data | output: output}
  defp filter(data), do: data
end
