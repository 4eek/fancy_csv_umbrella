defmodule Backend.CityTest do
  use Backend.Support.DbCase, async: false
  alias Backend.{City, Repo}

  defp valid_changeset do
    %City{}
    |> City.changeset(%{name: "Natal", url: "http://natal.com"})
  end

  test "inserts a valid record" do
    assert {:ok, _} = Repo.insert(valid_changeset())
  end

  test "does not insert when name is missing" do
    changeset = City.changeset(%City{}, %{name: nil, url: "http://natal.com"})

    assert {:error, changeset} = Repo.insert(changeset)
    assert {"can't be blank", _} = changeset.errors[:name]
  end

  test "does not insert when url is missing" do
    changeset = City.changeset(%City{}, %{name: "Foo", url: nil})

    assert {:error, changeset} = Repo.insert(changeset)
    assert {"can't be blank", _} = changeset.errors[:url]
  end

  test "counts the number of cities" do
    Repo.insert(valid_changeset())
    Repo.insert(valid_changeset())

    assert 2 = City.count
  end
end
