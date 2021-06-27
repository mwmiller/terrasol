defmodule Terrasol.Author do
  @doc """
  Parse an author address into a {name, pubkey} tuple.

  :error on invalid input
  """

  def parse(address)

  def parse(<<"@", name::binary-size(4), ".", encpub::binary-size(53)>>) do
    case {verifyname(name), Terrasol.bdecode(encpub)} do
      {_, :error} -> :error
      {:error, _} -> :error
      {shortname, key} -> {shortname, :binary.decode_unsigned(key, :little)}
    end
  end

  def parse(_), do: :error

  defp verifyname(string), do: checknamelist(to_charlist(string), [])
  defp checknamelist([f | rest], []) when f in 97..122, do: checknamelist(rest, [f])

  defp checknamelist([h | t], acc) when h in 97..122 or h in 48..57,
    do: checknamelist(t, [h | acc])

  defp checknamelist([], acc) when length(acc) == 4, do: acc |> Enum.reverse() |> to_string
  defp checknamelist(_, _), do: :error
end
