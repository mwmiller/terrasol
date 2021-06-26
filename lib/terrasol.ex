defmodule Terrasol do
  @alphabet 'abcdefghijklmnopqrstuvwxyz234567'
  BaseX.prepare_module("Earthstar", @alphabet, 4)

  @moduledoc """
  Documentation for `Terrasol`.
  """

  @doc """
  the Base32 encoding standard for Earthstar
  """
  def bencode(bits) do
    "b" <> BaseX.Earthstar.encode(bits)
  end

  def bdecode(<<"b", string::binary>>), do: BaseX.Earthstar.decode(string)
end
