defmodule Frontend.FeatureCase do
  use ExUnit.CaseTemplate

  defmodule Helpers do
    def start_session do
      metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Backend.Repo, self())
      {:ok, session} = Wallaby.start_session(metadata: metadata)

      session
    end
  end

  using do
    quote do
      use Wallaby.DSL
      import Wallaby.Query
      import Helpers

      @endpoint Frontend.Endpoint
      use Backend.Support.DbCase
      import Frontend.Router.Helpers
    end
  end
end
