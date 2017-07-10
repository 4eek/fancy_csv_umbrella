defmodule Frontend.CsvImportJob do
  alias Frontend.{BackgroundJob, ImportPath}
  alias Frontend.BackgroundJobChannel, as: Channel
  alias Backend.Csv
  alias Csv.Import.Options
  alias Plug.Upload

  @pid BackgroundJob.pid

  defstruct [:filename, :output, :message, ok: 0, error: 0]

  def enqueue(pid \\ @pid, %Upload{path: path, filename: filename}, %Options{} = options, output_dir) do
    {input_path, output_path} = ImportPath.resolve(output_dir, filename)
    options = %{options | input_path: input_path, output_path: output_path}

    File.mkdir_p Path.dirname(input_path)
    File.cp path, input_path

    do_enqueue pid, %__MODULE__{filename: filename}, options, output_dir
  end

  defp do_enqueue(pid, stats, options, output_dir) do
    BackgroundJob.add pid, stats, fn(id) ->
      Channel.send pid, "add", %{id: id, data: stats}

      Csv.Import.call options, fn(stats) ->
        Channel.send pid, "update", %{id: id, data: filter(stats, output_dir)}
      end
    end
  end

  def filter(%{output: nil} = stats, _output_dir), do: stats
  def filter(%{output: output} = stats, output_dir) do
    %{stats | output: String.replace(output, output_dir, "")}
  end
end
