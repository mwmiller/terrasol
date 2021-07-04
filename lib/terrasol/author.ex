defmodule Terrasol.Author do
  @enforce_keys [
    :string,
    :shortname,
    :publickey
  ]
  defstruct string: "",
            shortname: "",
            publickey: ""

  @typedoc "An Earthstar author"
  @type t() :: %__MODULE__{
          string: String.t(),
          shortname: String.t(),
          publickey: binary
        }
  defimpl String.Chars, for: Terrasol.Author do
    def to_string(author), do: "#{author.string}"
  end

  @doc """
  Parse an author address into a Terrasol.Author

  :error on invalid input
  """

  def parse(address)

  def parse(%Terrasol.Author{} = author), do: author

  def parse(<<"@", name::binary-size(4), ".", encpub::binary-size(53)>> = string) do
    case {verifyname(name), Terrasol.bdecode(encpub)} do
      {_, :error} -> :error
      {:error, _} -> :error
      {shortname, key} -> %Terrasol.Author{string: string, shortname: shortname, publickey: key}
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
