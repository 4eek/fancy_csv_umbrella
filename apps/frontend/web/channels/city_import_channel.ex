defmodule Frontend.CityImportChannel do
  use Phoenix.Channel

  def join("background_job", _message, socket) do
    send self(), :send_jobs

    {:ok, socket}
  end

  def handle_info(:send_jobs, socket) do
    jobs = Frontend.BackgroundJob.all
    |> Enum.map(&(&1.data |> Map.merge(%{id: &1.id})))

    push socket, "initialize", %{jobs: jobs}

    {:noreply, socket}
  end
end
