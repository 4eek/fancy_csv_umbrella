defmodule Frontend.CsvImportChannelTest do
  use Frontend.ChannelCase, async: false
  use Frontend.BackgroundJobCleanup
  alias Frontend.BackgroundJobChannel

  test "sends initial jobs upon connecting" do
    Frontend.BackgroundJob.add %{j1: "j1"}, fn(_) -> nil end

    {:ok, _, _socket} = socket("user:id", %{})
    |> subscribe_and_join(BackgroundJobChannel, "background_job")

    assert_push "initialize", %{jobs: [%{id: 1, data: %{j1: "j1"}}]}
  end
end
