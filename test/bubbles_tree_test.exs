defmodule Bubbles.TreeTest do
  use Bubbles.Tree.TestCase

  doctest Bubbles.Tree

  alias Bubbles.Tree.Test.{Category, Repo}

  test "deflats flat tree list" do
    deflattened =
      Bubbles.Tree.deflat([
        %{depth: 0, lft: 1, rgt: 32},
        %{depth: 1, lft: 2, rgt: 15},
        %{depth: 1, lft: 16, rgt: 19},
        %{depth: 1, lft: 20, rgt: 31},
        %{depth: 2, lft: 3, rgt: 10},
        %{depth: 2, lft: 11, rgt: 12},
        %{depth: 2, lft: 14, rgt: 14},
        %{depth: 2, lft: 17, rgt: 18},
        %{depth: 2, lft: 21, rgt: 28},
        %{depth: 2, lft: 29, rgt: 30},
        %{depth: 3, lft: 4, rgt: 5},
        %{depth: 3, lft: 6, rgt: 7},
        %{depth: 3, lft: 8, rgt: 9},
        %{depth: 3, lft: 22, rgt: 23},
        %{depth: 3, lft: 24, rgt: 25},
        %{depth: 3, lft: 26, rgt: 27}
      ])

    assert Enum.count(Enum.at(deflattened, 0).descendants) == 3
  end

  test "fetches categories with tree structure" do
    # Define initial tree structure
    top = Repo.insert!(%Category{name: "Top", lft: 1, rgt: 10, depth: 0})
    mid = Repo.insert!(%Category{name: "Mid 1", lft: 2, rgt: 7, depth: 1})
    Repo.insert!(%Category{name: "Mid 2", lft: 8, rgt: 9, depth: 1})
    Repo.insert!(%Category{name: "Low 1", lft: 3, rgt: 4, depth: 2})
    Repo.insert!(%Category{name: "Low 2", lft: 5, rgt: 6, depth: 2})

    # Test new insert into tree structure
    changeset = Category.changeset(%Category{}, %{name: "New last insert"})
    Bubbles.Tree.insert(Repo, Category, changeset, mid)
    changeset = Category.changeset(%Category{}, %{name: "New first insert"})
    Bubbles.Tree.insert(Repo, Category, changeset, mid, position: :first)

    top = Repo.get!(Category, top.id)
    IO.inspect(Bubbles.Tree.descendants(Repo, Category, top))
  end
end
