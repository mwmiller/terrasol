defmodule Terrasol do
  @moduledoc """
  Documentation for `Terrasol`.
  """

  @doc """
  the Base32 encoding standard for Earthstar
  """
  @base_opts [case: :lower, padding: false]
  def bencode(bits) do
    "b" <> Base.encode32(bits, @base_opts)
  end

  def bdecode(<<"b", string::binary>>) do
    case Base.decode32(string, @base_opts) do
      :error -> :error
      {:ok, val} -> val
    end
  end
end
