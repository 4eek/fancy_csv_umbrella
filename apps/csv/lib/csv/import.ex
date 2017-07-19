defmodule Csv.Import do
  alias Csv.RecordStream
  alias Csv.Import.{Stats, Options, Output}

  def call(%Options{input_path: input_path, type: type} = options, on_update) do
    {:ok, _} = File.open input_path, fn(input_device) ->
      case RecordStream.new(input_device, headers: options.headers, type: type) do
        {:ok, stream} -> import stream, options, on_update
        :invalid_csv -> abort "Invalid CSV headers", on_update
      end
    end
  end

  defp import(stream, options, on_update) do
    {:ok, _} = Output.open options.output_path, options.headers, fn(output_state) ->
      stream
      |> Task.async_stream(options.repo, :call, [], max_concurrency: options.max_concurrency)
      |> Stream.map(fn({:ok, changeset}) -> changeset end)
      |> Stream.map(&output_add_row(&1, output_state))
      |> Enum.reduce(Stats.new, &Stats.sum(&2, &1, on_update, freq: options.max_concurrency))
      |> Stats.finish(on_update, output: options.output_path)
    end
  end

  defp abort(message, on_update) do
    Stats.new
    |> Stats.finish(on_update, message: message)
  end

  defp output_add_row(changeset, output_state) do
    Output.add_row output_state, changeset
    changeset
  end
end
