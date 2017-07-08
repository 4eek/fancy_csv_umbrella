Code.require_file "db_case.exs", "test/support"

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]

Application.ensure_all_started :briefly

Ecto.Adapters.SQL.Sandbox.mode Backend.Repo, :manual

defmodule TestHelper do
  def read_stringio(handler), do: handler |> StringIO.contents |> contents
  defp contents({_, contents}), do: contents
end

defmodule Fixture do
  @fixtures_dir Path.join([File.cwd!, "test", "fixtures"])

  def path(filename) do
    Path.join(@fixtures_dir, filename)
  end
end

ExUnit.start()
