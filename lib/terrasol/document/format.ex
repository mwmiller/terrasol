defmodule Terrasol.Document.Format do
  @moduledoc """
  Behaviour for Document handler modules
  """
  @doc """
  The "format" value which this module handles
  """

  @callback format_string() :: String.t()
  @doc """
  Parse a map into a struct.

  Return {:invalid, [atoms for unvalidatable keys]}
  """
  @callback parse(map) :: map | {:invalid, [atom]}
  @doc """
  Build a struct from a supplied map using proper defaults

  Return {:invalid, [atoms for invalid supplied keys]}
  """
  @callback build(map) :: map | {:invalid, [atom]}
end
