defmodule Frontend.CityCsvJob do
  alias Frontend.{BackgroundJob, Endpoint, ImportPath}
  alias Backend.{Csv, City}

  defstruct ~w(id filename ok error output message)a

  @upload_base "priv/static"
  @format %Csv.Format{headers: ~w(name url)a, type: City}

  def enqueue(%Plug.Upload{path: source_path, filename: filename}) do
    {input_path, output_path} = ImportPath.resolve(@upload_base, filename)

    File.mkdir_p Path.dirname(input_path)
    File.cp source_path, input_path

    add_job %__MODULE__{filename: filename}, input_path, output_path
  end

  defp add_job(initial_stats, input_path, output_path) do
    BackgroundJob.add initial_stats, fn(job_id) ->
      Csv.Import.call input_path, output_path, @format, fn(job_stats) ->
        stats = job_stats |> filter

        BackgroundJob.update job_id, Map.delete(stats, :__struct__)
        Endpoint.broadcast("city_import:status", "change", stats)
      end
    end
  end

  defp filter(%{output: @upload_base <> output} = data), do: %{data | output: output}
  defp filter(data), do: data
end
