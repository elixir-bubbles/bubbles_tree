defmodule Bubbles.Tree.Test.Category do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field(:name, :string)
    belongs_to(:parent, __MODULE__)
    field(:lft, :integer)
    field(:rgt, :integer)
    field(:depth, :integer)
    field(:descendants, :any, virtual: true)
    field(:ancestors, :any, virtual: true)
    timestamps()
  end

  @doc false
  def changeset(%Bubbles.Tree.Test.Category{} = category, attrs) do
    category
    |> cast(attrs, [:name, :lft, :rgt, :depth])
    |> validate_required([:name])
  end
end
