defmodule Backend.Support.DbCase do
  use ExUnit.CaseTemplate
  alias Backend.Repo

  using do
    quote do
      alias Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
