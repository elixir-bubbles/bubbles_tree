defmodule Bubbles.Tree do
  @moduledoc """
  Documentation for Bubbles.Tree.
  """

  import Ecto.Query, only: [from: 2, update: 3]

  alias Ecto.Multi

  def children(repo_module, schema_module, struct) do
    query =
      from(
        t in schema_module,
        where: t.lft > ^struct.lft and t.rgt < ^struct.rgt and t.depth == ^(struct.depth + 1),
        order_by: [asc: :lft]
      )

    repo_module.all(query)
  end

  def set_children(repo_module, schema_module, struct) do
    Map.put(struct, :descendants, children(repo_module, schema_module, struct))
  end

  def descendants(repo_module, schema_module, struct, options \\ []) do
    query =
      from(
        t in schema_module,
        where: t.lft > ^struct.lft and t.rgt < ^struct.rgt,
        order_by: [asc: :lft]
      )

    descendants = repo_module.all(query)

    case options[:structure] do
      :flat -> descendants
      nil -> deflat(descendants)
    end
  end

  def set_descendants(repo_module, schema_module, struct, options \\ []) do
    Map.put(struct, :descendants, descendants(repo_module, schema_module, struct, options))
  end

  def deflat(list) do
    list
    |> Enum.sort(&(&1.depth < &2.depth))
    |> Enum.chunk_by(& &1.depth)
    |> deflat_chunks()
  end

  defp deflat_chunks([head | tail]) do
    case tail do
      [] ->
        head

      tail ->
        children = deflat_chunks(tail)

        Enum.map(head, fn struct ->
          Map.put(
            struct,
            :descendants,
            children
            |> Enum.filter(&(&1.lft > struct.lft and &1.rgt < struct.rgt))
            |> Enum.sort(&(&1.lft < &2.lft))
          )
        end)
    end
  end

  def insert(repo_module, schema_module, changeset, parent, options \\ []) do
    multi = insert_multi(schema_module, changeset, parent, options)
    repo_module.transaction(multi)
  end

  def insert_multi(schema_module, changeset, parent, options \\ []) do
    position = Keyword.get(options, :position, :last)

    case position do
      :first ->
        changeset =
          Ecto.Changeset.cast(
            changeset,
            %{lft: parent.lft + 1, rgt: parent.lft + 2, depth: parent.depth + 1},
            [:lft, :rgt, :depth]
          )

        Multi.new()
        |> Multi.update_all(
          :update_tree,
          from(t in schema_module, where: t.lft > ^parent.lft),
          inc: [rgt: 2, lft: 2]
        )
        |> Multi.update_all(
          :update_parent,
          from(t in schema_module, where: t.rgt == ^parent.rgt),
          inc: [rgt: 2]
        )
        |> Multi.insert(:insert, changeset)

      :last ->
        changeset =
          Ecto.Changeset.cast(
            changeset,
            %{lft: parent.rgt, rgt: parent.rgt + 1, depth: parent.depth + 1},
            [:lft, :rgt, :depth]
          )

        Multi.new()
        |> Multi.update_all(
          :update_tree,
          from(t in schema_module, where: t.rgt > ^parent.rgt),
          inc: [rgt: 2, lft: 2]
        )
        |> Multi.update_all(
          :update_parent,
          from(t in schema_module, where: t.rgt == ^parent.rgt),
          inc: [rgt: 2]
        )
        |> Multi.insert(:insert, changeset)
    end
  end

  def move(repo_module, schema_module, struct, options \\ []) do

  end

  def delete(repo_module, schema_module, struct) do

  end
end
