defmodule Terrasol.Workspace do
  @doc """
  Parse a workspace address into a {name, suffix} tuple.

  :error on invalid input
  """

  def parse(address)

  def parse(<<"+", nameplussuf::binary>>),
    do: nameplussuf |> to_charlist |> verifyname([])

  def parse(_), do: :error

  defp verifyname([f | rest], []) when f in 97..122, do: restname(rest, [f])
  defp verifyname(_, _), do: :error

  defp restname([h | t], name) when h in 48..57 or h in 97..122,
    do: restname(t, [h | name])

  defp restname([h | t], name) when h == 46, do: verifysuf(t, {name, []})

  defp restname([], _), do: :error

  defp verifysuf([f | rest], {n, []}) when f in 97..122, do: restsuf(rest, {n, [f]})
  defp verifysuf(_, _), do: :error

  defp restsuf([h | t], {n, s}) when h in 48..57 or h in 97..122,
    do: restsuf(t, {n, [h | s]})

  defp restsuf([], {n, s}) when length(n) <= 15 and length(s) <= 63,
    do: {Enum.reverse(n) |> to_string, Enum.reverse(s) |> to_string}

  defp restsuf(_, _), do: :error
end
