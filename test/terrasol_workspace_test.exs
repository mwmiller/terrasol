defmodule TerrasolWorkspaceTest do
  use ExUnit.Case
  doctest Terrasol.Workspace

  test "valid from spec" do
    assert Terrasol.Workspace.parse("+a.b") == %Terrasol.Workspace{
             name: "a",
             string: "+a.b",
             suffix: "b"
           }

    assert Terrasol.Workspace.parse("+gardening.friends") == %Terrasol.Workspace{
             name: "gardening",
             string: "+gardening.friends",
             suffix: "friends"
           }

    assert Terrasol.Workspace.parse("+gardening.j230d9qjd0q09of4j") ==
             %Terrasol.Workspace{
               name: "gardening",
               string: "+gardening.j230d9qjd0q09of4j",
               suffix: "j230d9qjd0q09of4j"
             }

    assert Terrasol.Workspace.parse(
             "+gardening.bnkksi5na3j7ifl5lmvxiyishmoybmu3khlvboxx6ighjv6crya5a"
           ) == %Terrasol.Workspace{
             name: "gardening",
             string: "+gardening.bnkksi5na3j7ifl5lmvxiyishmoybmu3khlvboxx6ighjv6crya5a",
             suffix: "bnkksi5na3j7ifl5lmvxiyishmoybmu3khlvboxx6ighjv6crya5a"
           }

    assert Terrasol.Workspace.parse("+bestbooks2019.o049fjafo09jaf") ==
             %Terrasol.Workspace{
               name: "bestbooks2019",
               string: "+bestbooks2019.o049fjafo09jaf",
               suffix: "o049fjafo09jaf"
             }
  end

  test "invalid from spec" do
    assert Terrasol.Workspace.parse("+a.b.c") == :error
    assert Terrasol.Workspace.parse("+80smusic.x") == :error
    assert Terrasol.Workspace.parse("+a.4ever") == :error
    assert Terrasol.Workspace.parse("PARTY.TIME") == :error
  end
end
