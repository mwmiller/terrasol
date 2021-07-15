defmodule Terrasol do
  @moduledoc """
  Documentation for `Terrasol`.
  """

  defimpl Jason.Encoder, for: [Terrasol.Author, Terrasol.Workspace, Terrasol.Path] do
    def encode(struct, opts) do
      Jason.Encode.string(struct.string, opts)
    end
  end

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

  def bdecode(_), do: :error

  @doc """
  Convert a duration into a number of microseconds.

  Integer durations are taken as a number of seconds.
  Keyword lists are interpreted for the implemented durations.
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
