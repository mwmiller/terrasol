defmodule TerrasolDocumentTest do
  use ExUnit.Case
  doctest Terrasol.Document

  test "parse" do
    spec_map = ExampleData.spec_map()

    assert %Terrasol.Document{} = spec_map |> Terrasol.Document.parse()
    assert %Terrasol.Document{} = spec_map |> Jason.encode!() |> Terrasol.Document.parse()

    assert {:invalid, [:author, :signature]} =
             spec_map |> Map.put(:author, "@a.b") |> Terrasol.Document.parse()

    assert {:invalid, [:signature]} =
             spec_map |> Map.put(:path, "/home") |> Terrasol.Document.parse()

    assert {:invalid, [:ephem_delete_mismatch, :signature]} =
             spec_map |> Map.put(:path, "/home!") |> Terrasol.Document.parse()

    assert {:invalid, [:deleteAfter, :signature]} =
             spec_map
             |> Map.put(:path, "/home!")
             |> Map.put(:deleteAfter, 9_999_999_999_999_999)
             |> Terrasol.Document.parse()
  end

  test "build" do
    test_author = ExampleData.test_author()
    assert %Terrasol.Document{} = Terrasol.Document.build(%{})
    assert {:invalid, [:author, :signature]} = Terrasol.Document.build(%{author: "@a.b"})

    assert {:invalid, [:signature]} ==
             Terrasol.Document.build(%{
               author: "@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             })

    assert %Terrasol.Document{} = Terrasol.Document.build(%{author: test_author})

    assert %Terrasol.Document{deleteAfter: da, timestamp: ts} =
             Terrasol.Document.build(%{author: test_author, ttl: [minutes: 383]})

    assert 22_980_000_000 == da - ts

    assert %Terrasol.Document{content: "Test greetings!", deleteAfter: nil} =
             Terrasol.Document.build(%{content: "Test greetings!"})

    assert {:invalid, [:ephem_delete_mismatch]} ==
             Terrasol.Document.build(%{content: "Test greetings!", path: "/home!"})

    assert %Terrasol.Document{path: %Terrasol.Path{string: "/home!"}} =
             Terrasol.Document.build(%{
               content: "Test greetings!",
               path: "/home!",
               ttl: [seconds: 20]
             })

    assert %Terrasol.Document{content: "Test greetings!"} =
             Terrasol.Document.build(%{author: test_author, content: "Test greetings!"})

    assert {:invalid, [:signature]} ==
             Terrasol.Document.build(%{
               author: "@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
               content: "Test greetings!"
             })
  end
end
