defmodule TerrasolPathTest do
  use ExUnit.Case
  doctest Terrasol.Path

  test "valid from ref test suite" do
    assert %Terrasol.Path{} = Terrasol.Path.parse("/foo")
    assert %Terrasol.Path{} = Terrasol.Path.parse("/FOO")
    assert %Terrasol.Path{} = Terrasol.Path.parse("/1234/5678")
    assert %Terrasol.Path{} = Terrasol.Path.parse("/a/b/c/d/e/f/g/h")
    assert %Terrasol.Path{} = Terrasol.Path.parse("/wiki/shared/Garden%20Gnome")
    assert %Terrasol.Path{} = Terrasol.Path.parse("/'()-._~!$&+,:=@%")
    assert %Terrasol.Path{} = Terrasol.Path.parse("/" <> String.duplicate("a", 511))
    assert %Terrasol.Path{ephemeral: true} = Terrasol.Path.parse("/foo!")
    assert %Terrasol.Path{ephemeral: true} = Terrasol.Path.parse("/foo!!")
    assert %Terrasol.Path{ephemeral: true} = Terrasol.Path.parse("/!foo")
    assert %Terrasol.Path{} = Terrasol.Path.parse(URI.encode("/food/🍆/nutrition"))
  end

  test "invalid from ref test suite" do
    assert :error = Terrasol.Path.parse("/" <> String.duplicate("a", 512))
    assert :error = Terrasol.Path.parse("")
    assert :error = Terrasol.Path.parse(" ")
    assert :error = Terrasol.Path.parse(<<0>>)
    assert :error = Terrasol.Path.parse("/")
    assert :error = Terrasol.Path.parse("a")
    assert :error = Terrasol.Path.parse("not/starting/with/slash")
    assert :error = Terrasol.Path.parse("/ends/with/slash/")
    assert :error = Terrasol.Path.parse(" /starts-with-space")
    assert :error = Terrasol.Path.parse("/ends-with-space ")
    assert :error = Terrasol.Path.parse("/space in the middle")
    assert :error = Terrasol.Path.parse("/double//slash/in/middle")
    assert :error = Terrasol.Path.parse("//double/slash/at/start")
    assert :error = Terrasol.Path.parse("/double/slash/at/end//")
    assert :error = Terrasol.Path.parse("/open-bracket<")
    assert :error = Terrasol.Path.parse("/question-mark?")
    assert :error = Terrasol.Path.parse("/asterisk*")
    assert :error = Terrasol.Path.parse("/newline\n")
    assert :error = Terrasol.Path.parse("/tab\t")
    assert :error = Terrasol.Path.parse("/@starts/with/at/sign")
    assert :error = Terrasol.Path.parse("/food/🍆/nutrition")
  end

  test "they say legal, I say no" do
    assert :error = Terrasol.Path.parse("/about/~@suzy.abc/name")
  end
end
