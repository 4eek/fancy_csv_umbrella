defmodule Frontend.CsvImportJob do
  alias Frontend.{BackgroundJob, Endpoint, ImportPath}
  alias Backend.Csv
  alias Csv.Import.Options
  alias Plug.Upload

  @pid BackgroundJob.pid

  defstruct [:filename, :output, :message, ok: 0, error: 0]

  def enqueue(pid \\ @pid, %Upload{path: path, filename: filename}, %Options{} = options, output_dir) do
    {input_path, output_path} = ImportPath.resolve(output_dir, filename)

    File.mkdir_p Path.dirname(input_path)
    File.cp path, input_path

    do_enqueue pid, %__MODULE__{filename: filename}, options, output_dir, input_path, output_path
  end

  defp do_enqueue(pid, stats, options, output_dir, input_path, output_path) do
    BackgroundJob.add pid, stats, fn(id) ->
      broadcast pid, "add", %{id: id, data: stats}

      Csv.Import.call input_path, output_path, options, fn(stats) ->
        broadcast pid, "update", %{id: id, data: stats |> filter(output_dir)}
      end
    end
  end

  defp broadcast(pid, event_name, data) do
    BackgroundJob.update pid, data
    Endpoint.broadcast "background_job", event_name, data
  end

  def filter(%{output: nil} = stats, _output_dir), do: stats
  def filter(%{output: output} = stats, output_dir) do
    %{stats | output: String.replace(output, output_dir, "")}
  end
end
