defmodule Backend.Csv.RecordStreamTest do
  use ExUnit.Case
  alias Backend.{Csv, City}

  setup do
    {:ok, options: [headers: ~w(name url)a, type: City]}
  end

  test "streams nothing when csv has no rows", %{options: options} do
    {:ok, device} = StringIO.open("name,url\n")
    {:ok, stream} = Csv.RecordStream.new(device, options)

    assert [] == Enum.to_list(stream)
  end

  test "converts csv records to structs and streams them", %{options: options} do
    {:ok, device} = StringIO.open """
    name,url
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    New York,http://newyork.org
    """
    {:ok, stream} = Csv.RecordStream.new(device, options)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = Enum.to_list(stream)
  end

  test "streams correctly when headers are swapped out", %{options: options} do
    {:ok, device} = StringIO.open """
    url,name
    http://madrid.com,Madrid
    http://natal.com.br,Natal
    http://newyork.org,New York
    """
    {:ok, stream} = Csv.RecordStream.new(device, options)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = Enum.to_list(stream)
  end

  test "returns invalid_csv when missing a required column", %{options: options} do
    {:ok, device} = StringIO.open """
    name
    Madrid
    Natal
    """

    assert :invalid_csv == Csv.RecordStream.new(device, options)
  end

  test "returns invalid_csv when column has wrong name", %{options: options} do
    {:ok, device} = StringIO.open """
    name,urls
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    """

    assert :invalid_csv == Csv.RecordStream.new(device, options)
  end
end
