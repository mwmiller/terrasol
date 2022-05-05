defmodule TerrasolDocumentTest do
  use ExUnit.Case
  doctest Terrasol.Document

  test "parse" do
    spec_map = ExampleData.es4_spec_map()

    assert %Terrasol.Document{content: %Terrasol.Document.ES4{}} =
             spec_map |> Terrasol.Document.parse()

    assert %Terrasol.Document{content: %Terrasol.Document.ES4{}} =
             spec_map |> Jason.encode!() |> Terrasol.Document.parse()
  end

  test "build" do
    assert %Terrasol.Document{content: %Terrasol.Document.ES4{}} = Terrasol.Document.build(%{})
    assert {:invalid, [:author, :signature]} = Terrasol.Document.build(%{author: "@a.b"})
  end
end
