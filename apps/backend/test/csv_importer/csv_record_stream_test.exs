defmodule Backend.CsvRecordStreamTest do
  use ExUnit.Case
  alias Backend.{City, CsvRecordStream}

  test "streams an empty collection when csv has no data lines" do
    {:ok, file_handler} = StringIO.open("name,url\n")
    {:ok, stream} = CsvRecordStream.create(file_handler)

    assert [] == Enum.to_list(stream)
  end

  test "streams records from a csv file" do
    {:ok, file_handler} = StringIO.open """
    name,url
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    New York,http://newyork.org
    """
    {:ok, stream} = CsvRecordStream.create(file_handler)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = Enum.to_list(stream)
  end

  test "streams the right contents when headers are switched out" do
    {:ok, file_handler} = StringIO.open """
    url,name
    http://madrid.com,Madrid
    http://natal.com.br,Natal
    http://newyork.org,New York
    """
    {:ok, stream} = CsvRecordStream.create(file_handler)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = Enum.to_list(stream)
  end

  test "returns invalid_csv when one of the columns is missing" do
    {:ok, file_handler} = StringIO.open """
    name
    Madrid
    Natal
    """

    assert :invalid_csv == CsvRecordStream.create(file_handler)
  end

  test "returns invalid_csv when one of the columns has wrong name" do
    {:ok, file_handler} = StringIO.open """
    name,urls
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    """

    assert :invalid_csv == CsvRecordStream.create(file_handler)
  end
end
