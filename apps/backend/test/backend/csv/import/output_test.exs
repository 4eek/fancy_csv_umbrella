defmodule Backend.Csv.Import.OutputTest do
  use ExUnit.Case
  alias Backend.{City, Csv} 

  defmodule FileMock do
    def start_link(path, return_value \\ nil) do
      {:ok, device} = StringIO.open("")
      Agent.start_link(fn -> {path, device, return_value} end, name: __MODULE__)
    end

    def open(path, [:write]) do
      {^path, device, return_value} = state()
      return_value || {:ok, device}
    end

    def close(pid), do: StringIO.close(pid)
    def device, do: elem(state(), 1)
    def state, do: Agent.get(__MODULE__, &(&1))
    def contents do
      {_, contents} = StringIO.contents(device())
      contents
    end
  end

  def changeset(map), do: struct(City, map) |> City.changeset
  def open_output(path, headers, callback) do
    FileMock.start_link path

    {:ok, _} = Csv.Import.Output.open path, headers, fn(output_state) ->
      send self(), "callback executed"
      callback.(output_state)
    end, FileMock

    assert_receive "callback executed"
    refute Process.alive?(FileMock.device)
  end

  test "creates a new output csv" do
    open_output "fake_path.csv", ~w(name url)a, fn(_) ->
      assert "name,url,errors\n" == FileMock.contents
    end
  end

  test "appends an invalid csv row to an output file" do
    open_output "fake_path.csv", ~w(name url)a, fn(output_state) ->
      changeset = changeset(%{name: nil, url: "http://i.com"})
      Csv.Import.Output.add_row output_state, {:error, changeset}

      assert """
      name,url,errors
      ,http://i.com,name can't be blank
      """ == FileMock.contents
    end
  end

  test "writes changeset fields in the output file by header order" do
    open_output "fake_path.csv", ~w(url name)a, fn(output_state) ->
      changeset = changeset(%{name: nil, url: "http://i.com"})
      Csv.Import.Output.add_row output_state, {:error, changeset}

      assert """
      url,name,errors
      http://i.com,,name can't be blank
      """ == FileMock.contents
    end
  end

  test "appends validation errors to output file correctly" do
    open_output "fake_path.csv", ~w(name url)a, fn(output_state) ->
      changeset = changeset(%{name: nil, url: nil})
      Csv.Import.Output.add_row output_state, {:error, changeset}

      assert """
      name,url,errors
      ,,"name can't be blank, url can't be blank"
      """ == FileMock.contents
    end
  end

  test "does not append a row to output file when changeset is valid" do
    open_output "fake_path.csv", ~w(name url)a, fn(output_state) ->
      changeset = changeset(%{name: "Town", url: "http://town.com"})
      Csv.Import.Output.add_row output_state, {:ok, changeset}

      assert "name,url,errors\n" = FileMock.contents
    end
  end

  test "returns an error when can not open device" do
    FileMock.start_link "fake_path.csv", {:error, "failed"}

    output = Csv.Import.Output.open "fake_path.csv", ~w(name url)a, fn(_) ->
      nil
    end, FileMock

    assert {:error, "failed"} = output
  end
end
