defmodule CsvImporter do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [worker(CsvImporter.Repo, [])],
      [strategy: :one_for_one, name: CsvImporter.Supervisor]
    )
  end
end
