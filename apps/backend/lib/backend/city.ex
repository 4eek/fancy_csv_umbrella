defmodule Backend.City do
  use Ecto.Schema

  schema "cities" do
    field :name, :string
    field :url, :string
  end

  def ordered do
    import Ecto.Query

    __MODULE__ |> order_by(asc: :name)
  end

  def changeset(city, params \\ %{}) do
    import Ecto.Changeset

    city
    |> cast(params, ~w(name url)a)
    |> validate_required(~w(name url)a)
  end
end
