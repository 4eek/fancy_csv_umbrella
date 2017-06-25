Code.require_file "db_case.exs", "test/support"

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]

Ecto.Adapters.SQL.Sandbox.mode(CsvImporter.Repo, :manual)

defmodule TestHelper do
  def read_stringio(handler), do: handler |> StringIO.contents |> contents
  defp contents({_, contents}), do: contents
end

ExUnit.start()
