ExUnit.start

:ok = Ecto.Adapters.SQL.Sandbox.checkout(Backend.Repo)
Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, {:shared, self()})
