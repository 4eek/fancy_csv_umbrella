defmodule Backend.ImportRecord do
  def call(%module{} = record) do
    record
    |> module.changeset
    |> Backend.Repo.insert
  end
end
