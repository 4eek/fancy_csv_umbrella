defmodule Frontend.JobRunnerCleanup do
  defmacro __using__(_opts) do
    quote do
      setup do
        on_exit fn ->
          Enum.each Frontend.JobRunner.all, fn(job) ->
            if Map.has_key?(job.data, :output) do
              Frontend.JobRunnerCleanup.delete_output_files(job)
            end
          end
        end

        Frontend.JobRunner.delete_all

        :ok
      end
    end
  end

  def delete_output_files(%{data: %{output: output}}) do
    files = Path.wildcard("**/#{Path.basename(output)}")

    Enum.each files, fn(file) ->
      :ok = File.rm(file)
    end
  end
end
