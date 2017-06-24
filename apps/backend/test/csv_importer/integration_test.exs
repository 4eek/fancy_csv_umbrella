defmodule CsvImporter.IntegrationTest do
  use DbCase
  alias CsvImporter.{CsvImporter, City, Repo, CsvRecordStream}

  defp extract_ok_result({:ok, stream}), do: stream

  test "creates records from a csv file" do
    {:ok, pid} = StringIO.open """
    name,url
    Natal,http://natal.com
    Madrid,http://madrid.org
    """

    pid
    |> CsvRecordStream.create
    |> extract_ok_result
    |> CsvImporter.call

    assert [
      %City{name: "Natal", url: "http://natal.com"},
      %City{name: "Madrid", url: "http://madrid.org"}
    ] = (City |> Repo.all)
  end
end
