defmodule TerrasolDocumentES4Test do
  use ExUnit.Case
  doctest Terrasol.Document

  test "parse" do
    spec_map = ExampleData.es4_spec_map()
    assert %Terrasol.Document.ES4{} = spec_map |> Terrasol.Document.ES4.parse()

    assert {:invalid, [:author, :signature]} =
             spec_map |> Map.put(:author, "@a.b") |> Terrasol.Document.ES4.parse()

    assert {:invalid, [:signature]} =
             spec_map |> Map.put(:path, "/home") |> Terrasol.Document.ES4.parse()

    assert {:invalid, [:ephem_delete_mismatch, :signature]} =
             spec_map |> Map.put(:path, "/home!") |> Terrasol.Document.ES4.parse()

    assert {:invalid, [:deleteAfter, :signature]} =
             spec_map
             |> Map.put(:path, "/home!")
             |> Map.put(:deleteAfter, 9_999_999_999_999_999)
             |> Terrasol.Document.ES4.parse()
  end

  test "build" do
    test_author = ExampleData.test_author()
    assert %Terrasol.Document.ES4{} = Terrasol.Document.ES4.build(%{})
    assert {:invalid, [:author, :signature]} = Terrasol.Document.ES4.build(%{author: "@a.b"})

    assert {:invalid, [:signature]} ==
             Terrasol.Document.ES4.build(%{
               author: "@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
             })

    assert %Terrasol.Document.ES4{} = Terrasol.Document.ES4.build(%{author: test_author})

    assert %Terrasol.Document.ES4{deleteAfter: da, timestamp: ts} =
             Terrasol.Document.ES4.build(%{author: test_author, ttl: [minutes: 383]})

    assert 22_980_000_000 == da - ts

    assert %Terrasol.Document.ES4{content: "Test greetings!", deleteAfter: nil} =
             Terrasol.Document.ES4.build(%{content: "Test greetings!"})

    assert {:invalid, [:ephem_delete_mismatch]} ==
             Terrasol.Document.ES4.build(%{content: "Test greetings!", path: "/home!"})

    assert %Terrasol.Document.ES4{path: %Terrasol.Path{string: "/home!"}} =
             Terrasol.Document.ES4.build(%{
               content: "Test greetings!",
               path: "/home!",
               ttl: [seconds: 20]
             })

    assert %Terrasol.Document.ES4{content: "Test greetings!"} =
             Terrasol.Document.ES4.build(%{author: test_author, content: "Test greetings!"})

    assert {:invalid, [:signature]} ==
             Terrasol.Document.ES4.build(%{
               author: "@suzy.bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
               content: "Test greetings!"
             })
  end
end
