defmodule Terrasol.Document do
  @moduledoc """
  Generic document handling

  One may add additional handlers which conform to the 
  `Terrasol.Document.Format` behaviour. These are controlled by
  `Config` parameters.  The default values are equivalent to:

  ```
  config :terrasol,
    load_default_format_mods: true,
    format_mods: []
  ```

  """
  defstruct [:format, :content]

  mods_to_load = fn ->
    head =
      case Application.compile_env(:terrasol, :load_default_format_mods) do
        {:ok, false} -> []
        # They need an explicit `false` to avoid this
        _ -> [Terrasol.Document.ES4]
      end

    tail =
      case Application.compile_env(:terrasol, :format_mods) do
        {:ok, list} -> list
        _ -> []
      end

    head ++ tail
  end

  @doc """
  Parse a map into a Terrasol.Document struct

  This consists of:

  `format`: the selected module
  `content`: an appropriate struct

  Strings are considered to be JSON maps and decoded before use.

  Returns `:error` on an unparseable map. tuple if a `Terrasol.Document.Format` handler returns same.
  Returns an :invalid tuple if a `Terrasol.Document.Format` handler returns same.
  """

  def parse(doc) when is_binary(doc) do
    try do
      doc
      |> Jason.decode!(keys: :atoms!)
      |> parse()
    rescue
      _ -> {:error, [:badjson]}
    end
  end

  def parse(doc), do: wrap_macroed(&parse_doc/1, doc)

  @doc """
  Build a Terrasol.Document from a supplied map applying appropriate defaults

  Defaults to "es.4" format.

  Returns `:error` on an unparseable map. tuple if a `Terrasol.Document.Format` handler returns same.
  Returns an :invalid tuple if a `Terrasol.Document.Format` handler returns same.
  """
  def build(%{format: _} = doc), do: wrap_macroed(&build_doc/1, doc)
  # Add missing defaults
  def build(doc), do: build(Map.merge(doc, %{format: "es.4"}))

  defp wrap_macroed(fun, doc) do
    case fun.(doc) do
      {_, {:invalid, errors}} -> {:invalid, errors}
      {module, doc} -> %__MODULE__{format: module, content: doc}
      _ -> :error
    end
  end

  for mod <- mods_to_load.() do
    defp parse_doc(%{format: unquote(mod.format_string())} = full),
      do: {unquote(mod), unquote(mod).parse(full)}

    defp build_doc(%{format: unquote(mod.format_string())} = full),
      do: {unquote(mod), unquote(mod).build(full)}
  end

  defp parse_doc(_), do: :error
  defp build_doc(_), do: :error
end
