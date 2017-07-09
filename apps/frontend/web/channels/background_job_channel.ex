defmodule Frontend.BackgroundJobChannel do
  use Phoenix.Channel

  def join("background_job", _message, socket) do
    send self(), :initialize

    {:ok, socket}
  end

  def handle_info(:initialize, socket) do
    push socket, "initialize", %{jobs: Frontend.BackgroundJob.all}

    {:noreply, socket}
  end
end
