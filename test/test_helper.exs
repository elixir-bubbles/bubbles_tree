defmodule Bubbles.Tree.TestCase do
  use ExUnit.CaseTemplate

  using opts do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bubbles.Tree.Test.Repo)
  end
end

Bubbles.Tree.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Bubbles.Tree.Test.Repo, :manual)

ExUnit.start()
