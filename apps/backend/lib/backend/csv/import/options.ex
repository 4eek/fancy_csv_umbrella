defmodule Backend.Csv.Import.Options do
  defstruct [:type, :headers, max_concurrency: 10]
end
