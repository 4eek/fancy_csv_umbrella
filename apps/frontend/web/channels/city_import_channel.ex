defmodule Frontend.CityImportChannel do
  use Phoenix.Channel

  def join("background_job", _message, socket) do
    send self(), :send_jobs

    {:ok, socket}
  end

  def handle_info(:send_jobs, socket) do
    push socket, "initialize", %{jobs: Frontend.BackgroundJob.all}

    {:noreply, socket}
  end
end
