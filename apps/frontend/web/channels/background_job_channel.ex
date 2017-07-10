defmodule Frontend.BackgroundJobChannel do
  use Phoenix.Channel
  alias Frontend.{BackgroundJob, Endpoint}

  def join("background_job", _message, socket) do
    send self(), :initialize

    {:ok, socket}
  end

  def handle_info(:initialize, socket) do
    push socket, "initialize", %{jobs: BackgroundJob.all}

    {:noreply, socket}
  end

  def send(pid, event_name, payload) do
    BackgroundJob.update pid, payload
    Endpoint.broadcast "background_job", event_name, payload
  end
end
