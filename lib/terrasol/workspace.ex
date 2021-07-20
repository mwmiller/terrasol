defmodule Terrasol.Workspace do
  @enforce_keys [
    :string,
    :name,
    :suffix
  ]
  defstruct string: "",
            name: "",
            suffix: ""

  @typedoc "An Earthstar workspace"
  @type t() :: %__MODULE__{
          string: String.t(),
          name: String.t(),
          suffix: String.t()
        }
  defimpl String.Chars, for: Terrasol.Workspace do
    def to_string(ws), do: "#{ws.string}"
  end

  @doc """
  Parse a workspace address into a %Terrasol.Workspace.

  :error on invalid input
  """

  def parse(address)
  def parse(%Terrasol.Workspace{} = ws), do: ws

  def parse(<<"+", nameplussuf::binary>> = orig),
    do: nameplussuf |> to_charlist |> verifyname(orig, [])

  def parse(_), do: :error

  defp verifyname([f | rest], orig, []) when f in 97..122, do: restname(rest, orig, [f])
  defp verifyname(_, _, _), do: :error

  defp restname([h | t], orig, name) when h in 48..57 or h in 97..122,
    do: restname(t, orig, [h | name])

  defp restname([h | t], orig, name) when h == 46, do: verifysuf(t, orig, {name, []})

  defp restname(_, _, _), do: :error

  defp verifysuf([f | rest], orig, {n, []}) when f in 97..122, do: restsuf(rest, orig, {n, [f]})
  defp verifysuf(_, _, _), do: :error

  defp restsuf([h | t], orig, {n, s}) when h in 48..57 or h in 97..122,
    do: restsuf(t, orig, {n, [h | s]})

  defp restsuf([], _, {[], _}), do: :error
  defp restsuf([], _, {_, []}), do: :error

  defp restsuf([], orig, {n, s}) when length(n) <= 15 and length(s) <= 53,
    do: %Terrasol.Workspace{
      string: orig,
      name: Enum.reverse(n) |> to_string,
      suffix: Enum.reverse(s) |> to_string
    }

  defp restsuf(_, _, _), do: :error
end
