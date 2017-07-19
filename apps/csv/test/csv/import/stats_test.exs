defmodule Csv.Import.StatsTest do
  use ExUnit.Case
  alias Csv.Import.Stats

  @ok_changeset {:ok, :fake_changeset}
  @error_changeset {:error, :fake_changeset}

  setup do
    {:ok, send_to_self: &(send self(), &1)}
  end

  test "has 0 ok and 0 error records when new" do
    assert %{ok: 0, error: 0} = Stats.new
  end

  defp assert_receive_count(count) do
    {:messages, messages} = Process.info(self(), :messages)
    assert count == messages |> Enum.count
  end

  test "adds 1 ok record", %{send_to_self: send_to_self} do
    assert %{ok: 1, error: 0} = Stats.new
    |> Stats.sum(@ok_changeset, send_to_self, freq: 1)

    assert_receive_count 1
    assert_receive %{ok: 1, error: 0}
  end

  test "adds 2 ok records", %{send_to_self: send_to_self} do
    assert %{ok: 2, error: 0} = Stats.new
    |> Stats.sum(@ok_changeset, send_to_self, freq: 1)
    |> Stats.sum(@ok_changeset, send_to_self, freq: 1)

    assert_receive_count 2
    assert_receive %{ok: 1, error: 0}
    assert_receive %{ok: 2, error: 0}
  end

  test "adds 1 error record", %{send_to_self: send_to_self} do
    assert %{ok: 0, error: 1} = Stats.new
    |> Stats.sum(@error_changeset, send_to_self, freq: 1)

    assert_receive_count 1
    assert_receive %{ok: 0, error: 1}
  end

  test "adds 2 error records", %{send_to_self: send_to_self} do
    assert %{ok: 0, error: 2} = Stats.new
    |> Stats.sum(@error_changeset, send_to_self, freq: 1)
    |> Stats.sum(@error_changeset, send_to_self, freq: 1)

    assert_receive_count 2
    assert_receive %{ok: 0, error: 1}
    assert_receive %{ok: 0, error: 2}
  end

  test "adds both ok and error records", %{send_to_self: send_to_self} do
    assert %{ok: 3, error: 2} = Stats.new
    |> Stats.sum(@ok_changeset, send_to_self, freq: 1)
    |> Stats.sum(@error_changeset, send_to_self, freq: 1)
    |> Stats.sum(@ok_changeset, send_to_self, freq: 1)
    |> Stats.sum(@error_changeset, send_to_self, freq: 1)
    |> Stats.sum(@ok_changeset, send_to_self, freq: 1)

    assert_receive_count 5
    assert_receive %{ok: 1, error: 0}
    assert_receive %{ok: 1, error: 1}
    assert_receive %{ok: 2, error: 1}
    assert_receive %{ok: 2, error: 2}
    assert_receive %{ok: 3, error: 2}
  end

  test "sends messages in the given frequency", %{send_to_self: send_to_self} do
    Stats.new
    |> Stats.sum(@ok_changeset, send_to_self, freq: 2)
    |> Stats.sum(@error_changeset, send_to_self, freq: 2)
    |> Stats.sum(@ok_changeset, send_to_self, freq: 2)
    |> Stats.sum(@error_changeset, send_to_self, freq: 2)
    |> Stats.sum(@ok_changeset, send_to_self, freq: 2)

    assert_receive_count 3
    assert_receive %{ok: 1, error: 0}
    assert_receive %{ok: 2, error: 1}
    assert_receive %{ok: 3, error: 2}
  end

  test "finishes with a message", %{send_to_self: send_to_self} do
    assert %{ok: 0, error: 0, message: "Error"} = Stats.new
    |> Stats.finish(send_to_self, message: "Error")

    assert_receive_count 1
    assert_receive %{message: "Error"}
  end

  test "finishes with an output_path", %{send_to_self: send_to_self} do
    assert %{ok: 0, error: 0, output: "/file.csv"} = Stats.new
    |> Stats.finish(send_to_self, output: "/file.csv")

    assert_receive_count 1
    assert_receive %{output: "/file.csv"}
  end

  test "does not update with invalid state", %{send_to_self: send_to_self} do
    assert_raise FunctionClauseError, fn ->
      assert %{ok: 0, error: 0, output: "/file.csv"} = Stats.new
      |> Stats.finish(send_to_self, invalid: "invalid")
    end
  end
end
