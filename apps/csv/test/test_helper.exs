ExUnit.start()

Application.ensure_all_started :briefly

defmodule Csv.Mocks.Record do
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :url, :string
  end

  def changeset(fixture, params \\ %{}) do
    fixture
    |> Ecto.Changeset.cast(params, ~w(name url)a)
    |> Ecto.Changeset.validate_required(~w(name url)a)
  end
end

defmodule Csv.TestHelpers.Fixture do
  @fixtures_dir Path.join([File.cwd!, "test", "fixtures"])

  def path(filename) do
    Path.join(@fixtures_dir, filename)
  end
end

defmodule Csv.Mocks.Repo do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def call(%mod{} = record) do
    changeset = mod.changeset(record)

    if changeset.valid? do
      Agent.update __MODULE__, &([record | &1])
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  def all do
    Agent.get(__MODULE__, &(&1))
  end
end

