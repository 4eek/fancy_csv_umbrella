defmodule Frontend.CsvImportJob do
  alias Frontend.{BackgroundJob, Endpoint, ImportPath}
  alias Backend.{Csv, City}

  defstruct id: nil, filename: nil, ok: 0, error: 0, output: nil, message: nil

  @upload_base "priv/static"
  @format %Csv.Format{headers: ~w(name url)a, type: City}

  def enqueue(%Plug.Upload{path: source_path, filename: filename}) do
    {input_path, output_path} = ImportPath.resolve(@upload_base, filename)

    File.mkdir_p Path.dirname(input_path)
    File.cp source_path, input_path

    do_enqueue %__MODULE__{filename: filename}, input_path, output_path
  end

  defp do_enqueue(initial_stats, input_path, output_path) do
    BackgroundJob.add initial_stats, fn(job_id) ->
      Endpoint.broadcast "background_job", "add", initial_stats |> Map.merge(%{id: job_id})

      Csv.Import.call input_path, output_path, 10, @format, fn(job_stats) ->
        stats = job_stats |> Map.merge(%{id: job_id}) |> filter |> Map.delete(:__struct__)

        BackgroundJob.update job_id, stats
        Endpoint.broadcast "background_job", "update", stats
      end
    end
  end

  defp filter(%{output: @upload_base <> output} = data), do: %{data | output: output}
  defp filter(data), do: data
end
