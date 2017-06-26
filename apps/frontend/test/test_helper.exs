ExUnit.start

:ok = Ecto.Adapters.SQL.Sandbox.checkout(CsvImporter.Repo)
Ecto.Adapters.SQL.Sandbox.mode(CsvImporter.Repo, {:shared, self()})
