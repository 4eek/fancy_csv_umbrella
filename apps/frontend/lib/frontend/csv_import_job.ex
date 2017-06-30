defmodule Frontend.CityCsvJob do
  @upload_path "priv/static/files"
  @tmp_upload_path Path.join(@upload_path, "tmp")
  @format %Backend.Csv.Format{headers: ~w(name url)a, type: Backend.City}

  def enqueue(%Plug.Upload{filename: filename} = file) do
    {input_path, output_path} = prepare_paths(file)

    Frontend.JobTracker.add fn %{id: id} ->
      Frontend.JobTracker.update(%{id: id, filename: filename})
      Backend.Csv.Importer.call(input_path, output_path, @format, &broadcast_status(id, &1))
    end
  end

  defp broadcast_status(id, status) do
    Process.sleep(2_000)
    data = status |> Map.merge(%{id: id})
    Frontend.JobTracker.update data
    Frontend.Endpoint.broadcast("city_import:status", "change", data)
  end

  defp prepare_paths(%Plug.Upload{path: tmp_path, filename: filename}) do
    filename = filename(filename)
    input_path = Path.join(@tmp_upload_path, filename)
    output_path = Path.join(@upload_path, filename)

    File.mkdir_p @tmp_upload_path
    File.cp tmp_path, input_path

    {input_path, output_path}
  end

  defp filename(filename) do
    suffix = Ecto.UUID.generate |> binary_part(16, 16)
    filename = filename |> Path.basename |> Path.rootname

    filename <> suffix <> ".csv"
  end
end
