defmodule Terrasol.Document do
  @moduledoc """
  The core document struct
  """
  @enforce_keys [
    :author,
    :content,
    :contentHash,
    :deleteAfter,
    :format,
    :path,
    :signature,
    :timestamp,
    :workspace
  ]
  defstruct author: "",
            content: "",
            contentHash: "",
            deleteAfter: nil,
            format: "es.4",
            path: "",
            signature: "",
            timestamp: 1,
            workspace: ""

  @typedoc "An Earthstar document"
  @type t() :: %__MODULE__{
          author: String.t(),
          content: binary(),
          contentHash: String.t(),
          deleteAfter: pos_integer(),
          format: String.t(),
          path: String.t(),
          signature: String.t(),
          timestamp: pos_integer(),
          workspace: String.t()
        }

  def validate(document)

  def validate(%__MODULE__{} = doc) do
    validate_fields(
      doc,
      [
        :author,
        :content,
        :contentHash,
        :deleteAfter,
        :format,
        :path,
        :signature,
        :timestamp,
        :workspace
      ],
      []
    )
  end

  def validate(_), do: {:error, [:nondocument]}

  defp validate_fields(doc, [], []), do: {:ok, doc}
  defp validate_fields(_, [], errs), do: {:invalid, Enum.sort(errs)}

  defp validate_fields(doc, [f | rest], errs) when f == :author do
    errlist =
      case Terrasol.Author.parse(doc.author) do
        {_, _} -> errs
        :error -> [f | errs]
      end

    validate_fields(doc, rest, errlist)
  end

  defp validate_fields(doc, [f | rest], errs) when f == :workspace do
    errlist =
      case Terrasol.Workspace.parse(doc.workspace) do
        {_, _} -> errs
        :error -> [f | errs]
      end

    validate_fields(doc, rest, errlist)
  end

  defp validate_fields(doc, [f | rest], errs) when f == :format do
    errlist =
      case doc.format do
        "es.4" -> errs
        _ -> [f | errs]
      end

    validate_fields(doc, rest, errlist)
  end

  @min_ts 10_000_000_000_000
  @max_ts 9_007_199_254_740_990

  defp validate_fields(doc, [f | rest], errs) when f == :timestamp do
    # Spec max int or 10 minutes into the future
    max_allowed = Enum.min([@max_ts, :erlang.system_time(:microsecond) + 600_000_000])

    val = doc.timestamp

    errlist =
      case is_integer(val) and val >= @min_ts and val <= max_allowed do
        true -> errs
        false -> [f | errs]
      end

    validate_fields(doc, rest, errlist)
  end

  @max_doc_bytes 4_000_000
  defp validate_fields(doc, [f | rest], errs) when f == :content do
    val = doc.content

    errlist =
      case byte_size(val) < @max_doc_bytes and String.valid?(val) do
        true -> errs
        false -> [f | errs]
      end

    validate_fields(doc, rest, errlist)
  end

  defp validate_fields(doc, [f | rest], errs) when f == :contentHash do
    computed_hash = :crypto.hash(:sha256, doc.content)

    published_hash =
      case Terrasol.bdecode(doc.contentHash) do
        :error -> ""
        val -> val
      end

    errlist =
      case Equivalex.equal?(computed_hash, published_hash) do
        true -> errs
        false -> [f | errs]
      end

    validate_fields(doc, rest, errlist)
  end

  # Skip unimplemented checks
  defp validate_fields(doc, [_f | rest], errs), do: validate_fields(doc, rest, errs)
end
