defmodule Terrasol.Path do
  @moduledoc """
  Handling of Earthstar path strings and the resulting
  `Terrasol.Path.t` structures
  """
  @upper ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  @lower ~c"abcdefghijklmnopqrstuvwxyz"
  @digit ~c"0123456789"
  @puncs ~c"'()-._~!$&+,:=@%"
  @allow @upper ++ @lower ++ @digit ++ @puncs

  @enforce_keys [
    :string,
    :segments,
    :ephemeral,
    :writers
  ]
  defstruct string: "",
            segments: [],
            ephemeral: false,
            writers: []

  @typedoc "An Earthstar path"
  @type t() :: %__MODULE__{
          string: String.t(),
          segments: [String.t()],
          ephemeral: boolean(),
          writers: [Terrasol.Author.t()]
        }
  defimpl String.Chars, for: Terrasol.Path do
    def to_string(path), do: "#{path.string}"
  end

  @doc """
  Parse an Earthstar path string into a `Terrasol.Path`

  `:error` on invalid input
  """

  def parse(path)

  def parse(%Terrasol.Path{} = path), do: path

  def parse(path) when is_binary(path) and byte_size(path) >= 2 and byte_size(path) <= 512 do
    case String.split(path, "/") do
      # Starts with "/"
      ["" | rest] -> parse_segments(rest, [], path, false, [])
      _ -> :error
    end
  end

  def parse(_), do: :error

  # "/"
  defp parse_segments([], [], _, _, _), do: :error

  defp parse_segments([], segments, string, ephemeral, writers),
    do: %__MODULE__{
      string: string,
      segments: Enum.reverse(segments),
      ephemeral: ephemeral,
      writers: writers
    }

  defp parse_segments([s | rest], seg, orig, ephem, writers) do
    case parse_seg(to_charlist(s), [], seg, ephem, writers) do
      :error -> :error
      {segments, ephemeral, writers} -> parse_segments(rest, segments, orig, ephemeral, writers)
    end
  end

  # // (empty segment)
  defp parse_seg([], [], _, _, _), do: :error

  # /@ at start
  defp parse_seg([64 | _], [], [], _, _), do: :error

  defp parse_seg([], curr, segments, ephem, write) do
    restring = curr |> Enum.reverse() |> to_string
    {[restring | segments], ephem, write}
  end

  # ! - set ephemeral
  defp parse_seg([33 | rest], curr, s, _, w), do: parse_seg(rest, [33 | curr], s, true, w)

  # ~ - set writer
  defp parse_seg([126 | rest], [], s, e, w) do
    restring = rest |> to_string

    case collect_writers(String.split(restring, "~"), w) do
      :error -> :error
      writers -> {["~" <> restring | s], e, writers}
    end
  end

  defp parse_seg([c | rest], curr, s, e, w) when c in @allow do
    parse_seg(rest, [c | curr], s, e, w)
  end

  defp parse_seg(_, _, _, _, _), do: :error

  # I don't think the order matters, but we'll maintain 
  defp collect_writers([], writers), do: Enum.reverse(writers)

  defp collect_writers([w | rest], writers) do
    case Terrasol.Author.parse(w) do
      :error -> :error
      writer -> collect_writers(rest, [writer | writers])
    end
  end
end
