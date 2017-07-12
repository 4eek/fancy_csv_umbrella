defmodule Frontend.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      import Wallaby.Query

      @endpoint Frontend.Endpoint
      use Backend.Support.DbCase
      import Frontend.Router.Helpers
    end
  end

  setup do
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Backend.Repo, self())

    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
