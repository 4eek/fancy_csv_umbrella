defmodule Frontend.CsvImportChannelTest do
  use Frontend.ChannelCase
  alias Frontend.BackgroundJobChannel

  test "works" do
    {:ok, _, _socket} = socket("", %{})
    |> subscribe_and_join(BackgroundJobChannel, "background_job")
  end
end
