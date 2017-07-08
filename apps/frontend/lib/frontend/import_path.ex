defmodule Frontend.ImportPath do
  def resolve(upload_base, filename, suffix \\ &default_suffix/0) do
    path = Path.join(upload_base, "files")
    filename = dest_filename(filename, suffix)

    input_path = Path.join([path, "tmp", filename])
    output_path = Path.join(path, filename)

    {input_path, output_path}
  end

  defp dest_filename(filename, suffix) do
    path_no_ext = filename |> Path.basename |> Path.rootname
    path_no_ext <> suffix.() <> ".csv"
  end

  defp default_suffix, do: Ecto.UUID.generate |> binary_part(16, 16)
end

