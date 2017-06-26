defmodule Frontend.CityCsvJob do
  @upload_path "priv/static/files"
  @tmp_upload_path Path.join(@upload_path, "tmp")

  def enqueue(file) do
    {input_path, output_path} = prepare_paths(file)

    Frontend.JobTracker.add fn _info ->
      {:ok, input_file_handler} = File.open(input_path)
      {:ok, output_file_handler} = File.open(output_path, [:write])

      CsvImporter.Main.import_file(input_file_handler, output_file_handler)
    end
  end

  defp prepare_paths(%Plug.Upload{path: tmp_path, filename: filename}) do
    filename = filename(filename)
    input_path = Path.join(@tmp_upload_path, filename)
    output_path = Path.join(@upload_path, filename)

    File.mkdir_p @tmp_upload_path
    File.cp tmp_path, input_path

    {input_path, output_path}
  end

  defp filename(fname) do
    suffix = Ecto.UUID.generate |> binary_part(16, 16)
    fname = fname |> Path.basename |> Path.rootname

    fname <> suffix <> ".csv"
  end
end
