defmodule Frontend.CsvImportChannelTest do
  use Frontend.ChannelCase, async: false
  use Frontend.JobRunnerCleanup
  alias Frontend.JobRunnerChannel

  test "sends initial jobs upon connecting" do
    Frontend.JobRunner.add %{j1: "j1"}, fn(_) -> nil end

    {:ok, _, _socket} = socket("user:id", %{})
    |> subscribe_and_join(JobRunnerChannel, "job_runner")

    assert_push "initialize", %{jobs: [%{id: 1, data: %{j1: "j1"}}]}
  end
end
