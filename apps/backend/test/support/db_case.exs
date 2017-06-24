defmodule DbCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      alias CsvImporter.Repo

      setup tags do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

        unless tags[:async] do
          Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
        end
      end
    end
  end
end
