defmodule Frontend.JobRunnerChannel do
  use Phoenix.Channel
  alias Frontend.{JobRunner, Endpoint}

  def join("job_runner", _message, socket) do
    send self(), :initialize

    {:ok, socket}
  end

  def handle_info(:initialize, socket) do
    push socket, "initialize", %{jobs: JobRunner.all}

    {:noreply, socket}
  end

  def send(pid, event_name, payload) do
    JobRunner.update pid, payload
    Endpoint.broadcast "job_runner", event_name, payload
  end
end
