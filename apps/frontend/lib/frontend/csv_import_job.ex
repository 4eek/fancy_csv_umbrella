defmodule Frontend.CityCsvJob do
  alias Frontend.{BackgroundJob, Endpoint}
  alias Backend.{Csv, City}

  @upload_base "priv/static"
  @upload_path "#{@upload_base}/files"
  @tmp_upload_path Path.join(@upload_path, "tmp")
  @format %Csv.Format{headers: ~w(name url)a, type: City}

  def enqueue(%Plug.Upload{filename: filename} = file) do
    {input_path, output_path} = prepare_paths(file)

    BackgroundJob.add fn %{id: id} ->
      BackgroundJob.update(%{id: id, filename: filename})
      Csv.Import.call(input_path, output_path, @format, &broadcast(id, &1))
    end
  end

  defp broadcast(id, status) do
    data = status
    |> Map.merge(%{id: id})
    |> transform_data()

    BackgroundJob.update data
    Endpoint.broadcast("city_import:status", "change", data)
  end

  defp transform_data(%{output: @upload_base <> output} = data) do
    data |> Map.put(:output, output)
  end

  defp transform_data(data), do: data

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
