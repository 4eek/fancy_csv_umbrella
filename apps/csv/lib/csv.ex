defmodule Csv do
  alias Csv.Import.Options

  defdelegate import(options, on_update), to: Csv.Import, as: :call
  def options(attributes \\ []), do: struct(Options, Enum.into(attributes, %{}))
end
