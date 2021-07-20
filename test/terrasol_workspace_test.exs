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

  test "valid from reference test suite" do
    assert Terrasol.Workspace.parse(
             "+gardening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
           ) == %Terrasol.Workspace{
             name: "gardening",
             string: "+gardening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
             suffix: "bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
           }

    assert Terrasol.Workspace.parse("+gardening.bxxxx") ==
             %Terrasol.Workspace{
               name: "gardening",
               string: "+gardening.bxxxx",
               suffix: "bxxxx"
             }

    assert Terrasol.Workspace.parse("+a.x") ==
             %Terrasol.Workspace{
               name: "a",
               string: "+a.x",
               suffix: "x"
             }

    assert Terrasol.Workspace.parse("+aaaaabbbbbccccc.bxxx") == %Terrasol.Workspace{
             name: "aaaaabbbbbccccc",
             string: "+aaaaabbbbbccccc.bxxx",
             suffix: "bxxx"
           }

    assert Terrasol.Workspace.parse("+gardening.r0cks") ==
             %Terrasol.Workspace{
               name: "gardening",
               string: "+gardening.r0cks",
               suffix: "r0cks"
             }

    assert Terrasol.Workspace.parse(
             "+garden2000.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
           ) ==
             %Terrasol.Workspace{
               name: "garden2000",
               string: "+garden2000.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
               suffix: "bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             }
  end

  test "invalid from reference test suite" do
    assert :error = Terrasol.Workspace.parse("")
    assert :error = Terrasol.Workspace.parse("+")

    assert :error =
             Terrasol.Workspace.parse(
               "gardening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+gardening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+gardeningbxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse("+.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

    assert :error = Terrasol.Workspace.parse("+gardening")
    assert :error = Terrasol.Workspace.parse("+gardening.")
    assert :error = Terrasol.Workspace.parse("gardening")

    assert :error =
             Terrasol.Workspace.parse(
               " +gardening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+gardening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+gardening.bxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+GARDENING.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+gardening.bXXXXXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+1garden.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+gar?dening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "++gardening.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )

    assert :error =
             Terrasol.Workspace.parse(
               "+garden🤡.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             )
  end
end
