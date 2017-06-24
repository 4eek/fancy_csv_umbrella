Code.require_file "db_case.exs", "test/support"

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]

Ecto.Adapters.SQL.Sandbox.mode(CsvImporter.Repo, :manual)

ExUnit.start()
