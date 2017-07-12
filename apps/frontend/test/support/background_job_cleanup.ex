defmodule Frontend.BackgroundJobCleanup do
  defmacro __using__(_opts) do
    quote do
      setup do
        on_exit fn ->
          Frontend.BackgroundJob.delete_all
        end

        :ok
      end
    end
  end
end
