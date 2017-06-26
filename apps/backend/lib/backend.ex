defmodule Backend do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [worker(Backend.Repo, [])],
      [strategy: :one_for_one, name: Backend.Supervisor]
    )
  end
end
