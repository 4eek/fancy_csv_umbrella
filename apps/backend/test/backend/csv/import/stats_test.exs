defmodule Backend.Csv.Import.StatsTest do
  use ExUnit.Case
  alias Backend.Csv.Import
  import Import.Stats

  test "has 0 ok and 0 error records when new" do
    assert %Import.Stats{ok: 0, error: 0} == new()
  end

  test "adds 1 ok record" do
    assert %Import.Stats{ok: 1, error: 0} == new() |> update(:ok)
  end

  test "adds 2 ok records" do
    assert %Import.Stats{ok: 2, error: 0} == new() |> update(:ok) |> update(:ok)
  end

  test "adds 1 error record" do
    assert %Import.Stats{ok: 0, error: 1} == new() |> update(:error)
  end

  test "adds 2 error records" do
    assert %Import.Stats{ok: 0, error: 2} == new() |> update(:error) |> update(:error)
  end

  test "adds both success and error records" do
    assert %Import.Stats{ok: 3, error: 2} == new()
    |> update(:ok)
    |> update(:error)
    |> update(:ok)
    |> update(:error)
    |> update(:ok)
  end

  test "updates with a message" do
    assert %Import.Stats{ok: 0, error: 0, message: "Error"} == new()
    |> update(message: "Error")
  end

  test "updates with the output path" do
    assert %Import.Stats{ok: 0, error: 0, output: "/file.csv"} == new()
    |> update(output: "/file.csv")
  end

  test "does not update with invalid state" do
    assert_raise FunctionClauseError, fn ->
      %Import.Stats{ok: 0, error: 0, output: "/file.csv"} == new()
      |> update(invalid: "invalid")
    end
  end
end
