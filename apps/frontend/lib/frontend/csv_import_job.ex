defmodule Frontend.CsvImportJob do
  alias Frontend.{BackgroundJob, Endpoint, ImportPath}
  alias Backend.Csv

  defstruct [:filename, :output, :message, ok: 0, error: 0]

  def enqueue(%Plug.Upload{path: path, filename: filename}, %Csv.Format{} = format, output_dir) do
    {input_path, output_path} = ImportPath.resolve(output_dir, filename)

    File.mkdir_p Path.dirname(input_path)
    File.cp path, input_path

    do_enqueue %__MODULE__{filename: filename}, format, output_dir, input_path, output_path
  end

  defp do_enqueue(stats, format, output_dir, input_path, output_path) do
    BackgroundJob.add stats, fn(id) ->
      broadcast "add", %{id: id, data: stats}

      Csv.Import.call input_path, output_path, 10, format, fn(stats) ->
        broadcast "update", %{id: id, data: stats |> filter(output_dir)}
      end
    end
  end

  defp broadcast(event_name, data) do
    BackgroundJob.update data
    Endpoint.broadcast "background_job", event_name, data
  end

  defp filter(stats, output_dir) do
    case stats do
      %{output: nil} ->
        stats
      %{output: output} ->
        %{stats | output: String.replace(output, output_dir, "")}
    end
  end
end
