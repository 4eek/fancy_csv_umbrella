defmodule Csv.Import.Options do
  defstruct [:input_path, :output_path, :type, :headers, :repo, max_concurrency: 10]
end
