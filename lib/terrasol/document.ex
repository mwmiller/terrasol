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
  @derive Jason.Encoder
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
          author: String.t() | Terrasol.Author.t(),
          content: binary(),
          contentHash: String.t(),
          deleteAfter: pos_integer(),
          format: String.t(),
          path: String.t(),
          signature: String.t(),
          timestamp: pos_integer(),
          workspace: String.t()
        }

  def compute_hash(doc) do
    Terrasol.bencode(
      :crypto.hash(
        :sha256,
        gather_fields(
          doc,
          [:author, :contentHash, :deleteAfter, :format, :path, :timestamp, :workspace],
          ""
        )
      )
    )
  end

  defp gather_fields(_, [], str), do: str

  defp gather_fields(doc, [f | rest], str) do
    case Map.fetch!(doc, f) do
      nil -> gather_fields(doc, rest, str)
      val -> gather_fields(doc, rest, str <> "#{f}\t#{val}\n")
    end
  end

  def parse(document)

  def parse(doc) when is_binary(doc) do
    try do
      doc
      |> Jason.decode!(keys: :atoms!)
      |> parse()
    rescue
      _ -> {:error, [:badjson]}
    end
  end

  def parse(%__MODULE__{} = doc) do
    parse_fields(
      doc,
      [
        :author,
        :content,
        :contentHash,
        :path,
        :deleteAfter,
        :format,
        :signature,
        :timestamp,
        :workspace
      ],
      []
    )
  end

  def parse(%{} = doc) do
    struct(__MODULE__, doc) |> parse
  end

  def parse(_), do: {:error, [:badformat]}

  defp parse_fields(doc, [], []), do: {:ok, doc}
  defp parse_fields(_, [], errs), do: {:invalid, Enum.sort(errs)}

  defp parse_fields(doc, [f | rest], errs) when f == :author do
    author = Terrasol.Author.parse(doc.author)

    errlist =
      case author do
        %Terrasol.Author{} -> errs
        :error -> [f | errs]
      end

    parse_fields(%{doc | author: author}, rest, errlist)
  end

  defp parse_fields(doc, [f | rest], errs) when f == :workspace do
    ws = Terrasol.Workspace.parse(doc.workspace)

    errlist =
      case ws do
        %Terrasol.Workspace{} -> errs
        :error -> [f | errs]
      end

    parse_fields(%{doc | workspace: ws}, rest, errlist)
  end

  defp parse_fields(doc, [f | rest], errs) when f == :path do
    path = Terrasol.Path.parse(doc.path)

    errlist =
      case path do
        %Terrasol.Path{} -> errs
        :error -> [f | errs]
      end

    parse_fields(%{doc | path: path}, rest, errlist)
  end

  defp parse_fields(doc, [f | rest], errs) when f == :format do
    errlist =
      case doc.format do
        "es.4" -> errs
        _ -> [f | errs]
      end

    parse_fields(doc, rest, errlist)
  end

  @min_ts 10_000_000_000_000
  @max_ts 9_007_199_254_740_990

  defp parse_fields(doc, [f | rest], errs) when f == :timestamp do
    # Spec max int or 10 minutes into the future
    max_allowed = Enum.min([@max_ts, :erlang.system_time(:microsecond) + 600_000_000])

    val = doc.timestamp

    errlist =
      case is_integer(val) and val >= @min_ts and val <= max_allowed do
        true -> errs
        false -> [f | errs]
      end

    parse_fields(doc, rest, errlist)
  end

  @max_doc_bytes 4_000_000
  defp parse_fields(doc, [f | rest], errs) when f == :content do
    val = doc.content

    errlist =
      case byte_size(val) < @max_doc_bytes and String.valid?(val) do
        true -> errs
        false -> [f | errs]
      end

    parse_fields(doc, rest, errlist)
  end

  @nul32 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
           0, 0, 0>>
  defp parse_fields(doc, [f | rest], errs) when f == :contentHash do
    computed_hash = :crypto.hash(:sha256, doc.content)

    published_hash =
      case Terrasol.bdecode(doc.contentHash) do
        :error -> @nul32
        val -> val
      end

    errlist =
      case Equivalex.equal?(computed_hash, published_hash) do
        true -> errs
        false -> [f | errs]
      end

    parse_fields(doc, rest, errlist)
  end

  defp parse_fields(doc, [f | rest], errs) when f == :signature do
    sig =
      case Terrasol.bdecode(doc.signature) do
        :error -> @nul32
        val -> val
      end

    author_pub_key =
      case Terrasol.Author.parse(doc.author) do
        :error -> @nul32
        %Terrasol.Author{publickey: pk} -> pk
      end

    errlist =
      case Ed25519.valid_signature?(sig, compute_hash(doc), author_pub_key) do
        true -> errs
        false -> [f | errs]
      end

    parse_fields(doc, rest, errlist)
  end

  # Skip unimplemented checks
  defp parse_fields(doc, [_f | rest], errs), do: parse_fields(doc, rest, errs)
end
