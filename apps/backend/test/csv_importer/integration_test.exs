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
    |> Enum.to_list

    assert [
      %City{name: "Madrid", url: "http://madrid.org"},
      %City{name: "Natal", url: "http://natal.com"}
    ] = (City.ordered |> Repo.all)
  end
end
