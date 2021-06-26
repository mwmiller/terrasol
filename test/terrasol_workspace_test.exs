defmodule TerrasolWorkspaceTest do
  use ExUnit.Case
  doctest Terrasol.Workspace

  test "valid from spec" do
    assert Terrasol.Workspace.parse("+a.b") == {"a", "b"}
    assert Terrasol.Workspace.parse("+gardening.friends") == {"gardening", "friends"}

    assert Terrasol.Workspace.parse("+gardening.j230d9qjd0q09of4j") ==
             {"gardening", "j230d9qjd0q09of4j"}

    assert Terrasol.Workspace.parse(
             "+gardening.bnkksi5na3j7ifl5lmvxiyishmoybmu3khlvboxx6ighjv6crya5a"
           ) == {"gardening", "bnkksi5na3j7ifl5lmvxiyishmoybmu3khlvboxx6ighjv6crya5a"}

    assert Terrasol.Workspace.parse("+bestbooks2019.o049fjafo09jaf") ==
             {"bestbooks2019", "o049fjafo09jaf"}
  end

  test "invalid from spec" do
    assert Terrasol.Workspace.parse("+a.b.c") == :error
    assert Terrasol.Workspace.parse("+80smusic.x") == :error
    assert Terrasol.Workspace.parse("+a.4ever") == :error
    assert Terrasol.Workspace.parse("PARTY.TIME") == :error
  end
end
