defmodule Backend.Csv.Import.Options do
  defstruct [:input_path, :output_path, :type, :headers, max_concurrency: 10]
end
