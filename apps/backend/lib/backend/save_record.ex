defmodule Backend.SaveRecord do
  def call(%mod{} = record) do
    record
    |> mod.changeset
    |> Backend.Repo.insert
  end
end
