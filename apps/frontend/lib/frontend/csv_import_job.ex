defmodule Frontend.CsvImportJob do
  alias Frontend.{BackgroundJob, Endpoint, ImportPath}
  alias Backend.{Csv, City}

  defstruct [:id, :filename, :output, :message, ok: 0, error: 0]

  @base_dir "priv/static"
  @format %Csv.Format{headers: ~w(name url)a, type: City}

  def enqueue(%Plug.Upload{path: source_path, filename: filename}) do
    {input_path, output_path} = ImportPath.resolve(@base_dir, filename)

    File.mkdir_p Path.dirname(input_path)
    File.cp source_path, input_path

    do_enqueue %__MODULE__{filename: filename}, input_path, output_path
  end

  defp do_enqueue(stats, input_path, output_path) do
    BackgroundJob.add stats, fn(id) ->
      broadcast "add", %{id: id, data: stats}

      Csv.Import.call input_path, output_path, 10, @format, fn(stats) ->
        broadcast "update", %{id: id, data: stats |> filter}
      end
    end
  end

  defp broadcast(event_name, data) do
    BackgroundJob.update data
    Endpoint.broadcast "background_job", event_name, data
  end

  defp filter(%{output: @base_dir <> output} = stats), do: %{stats | output: output}
  defp filter(stats), do: stats
end
