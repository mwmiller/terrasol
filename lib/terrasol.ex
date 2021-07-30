defmodule Terrasol do
  @moduledoc """
  Various utility functions to assist with some of the
  unique requirements for Earthstar documents.
  """

  defimpl Jason.Encoder, for: [Terrasol.Author, Terrasol.Workspace, Terrasol.Path] do
    def encode(struct, opts) do
      Jason.Encode.string(struct.string, opts)
    end
  end

  @doc """
  Encode the Base32 standard for Earthstar

  ## Examples
      iex> Terrasol.bencode("🤡💩")
      "b6cp2jipqt6jks"

      iex> Terrasol.bencode("abcdef")
      "bmfrggzdfmy"
  """
  @base_opts [case: :lower, padding: false]
  def bencode(bits) do
    "b" <> Base.encode32(bits, @base_opts)
  end

  @doc """
  Decode the Base32 standard for Earthstar

  ## Examples
      iex> Terrasol.bdecode("b6cp2jipqt6jks")
      "🤡💩"

      iex> Terrasol.bdecode("bmfrggzdfmy")
      "abcdef"

      iex> Terrasol.bdecode("mfrggzdfmy")
      :error
  """
  def bdecode(encoded_string)

  def bdecode(<<"b", string::binary>>) do
    case Base.decode32(string, @base_opts) do
      :error -> :error
      {:ok, val} -> val
    end
  end

  def bdecode(_), do: :error

  @doc """
  Convert a duration into a number of microseconds.

  Integer durations are taken as a number of seconds.

  Keyword lists are interpreted for the implemented durations.
  Unimplemented items are treated as 0

  :weeks, :days, :hours, :minutes
  :seconds, :milliseconds, :microseconds

  ## Examples
        iex> Terrasol.duration_us(600)
        600000000

        iex> Terrasol.duration_us(minutes: 10, microseconds: 321)
        600000321

        iex> Terrasol.duration_us("600s")
        0
  """
  def duration_us(duration)
  def duration_us(duration) when is_integer(duration), do: duration_us(seconds: duration)

  def duration_us(duration) do
    try do
      sum_dur(duration, duration |> Keyword.keys() |> Enum.uniq(), 0)
    rescue
      _ -> 0
    end
  end

  defp sum_dur(_, [], acc), do: acc

  @multipliers %{
    :microseconds => 1,
    :milliseconds => 1000,
    :seconds => 1_000_000,
    :minutes => 60_000_000,
    :hours => 3_600_000_000,
    :days => 86_400_000_000,
    :weeks => 604_800_000_000
  }

  defp sum_dur(dur, [label | rest], acc) do
    {vals, nd} = dur |> Keyword.pop_values(label)
    # Skip unknowns
    mul =
      case Map.fetch(@multipliers, label) do
        {:ok, val} -> val
        :error -> 0
      end

    sum_dur(nd, rest, acc + Enum.sum(vals) * mul)
  end
end
