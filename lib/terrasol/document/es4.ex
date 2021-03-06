defmodule Terrasol.Document.ES4 do
  @behaviour Terrasol.Document.Format
  @impl Terrasol.Document.Format
  def format_string, do: "es.4"

  @nul32 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
           0, 0, 0>>
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

  @moduledoc """
  Handling of the Earthstar "es.4" document format and the resulting
  structures
  """

  defp compute_hash(doc) do
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

  defp content_hash(doc), do: :crypto.hash(:sha256, doc.content)

  @doc """
  Build a `Terrasol.Document.ES4` from a map containing all or some of the required keys.

  This is resolved internally in a deterministic way which is implementation-specific
  and should not be depended upon to remain the same between versions.

  A `:ttl` key may be used. It will be parsed into a `:deleteAfter` using 
  the document timestamp and adding `Terrasol.duration_us(ttl)`

  The final value is passed through `parse/1` returning as that function does.
  """
  @impl Terrasol.Document.Format
  def build(map) do
    build(map, [
      :timestamp,
      :ttl,
      :deleteAfter,
      :format,
      :workspace,
      :path,
      :author,
      :content,
      :contentHash,
      :signature
    ])
  end

  defp build(map, []), do: parse(map)
  defp build(map, [key | rest]), do: build(val_or_gen(map, key), rest)

  defp val_or_gen(map, :ttl) do
    case Map.fetch(map, :ttl) do
      :error ->
        map

      {:ok, val} ->
        map
        |> Map.delete(:ttl)
        |> Map.put(:deleteAfter, map.timestamp + Terrasol.duration_us(val))
    end
  end

  defp val_or_gen(map, key) do
    case Map.fetch(map, key) do
      :error -> Map.put(map, key, default(key, map))
      _ -> map
    end
  end

  defp default(:timestamp, _), do: :erlang.system_time(:microsecond)
  defp default(:format, _), do: "es.4"
  defp default(:workspace, _), do: "+terrasol.scratch"

  defp default(:path, map) do
    case(Map.fetch(map, :deleteAfter)) do
      :error -> "/terrasol/scratch/default.txt"
      {:ok, nil} -> "/terrasol/scratch/default.txt"
      _ -> "/terrasol/scratch/!default.txt"
    end
  end

  defp default(:author, _), do: Terrasol.Author.build(%{})
  defp default(:content, _), do: "Auto-text from Terrasol."
  defp default(:contentHash, map), do: map |> content_hash |> Terrasol.bencode()
  defp default(:deleteAfter, _), do: nil

  defp default(:signature, map) do
    {priv, pub} =
      case Terrasol.Author.parse(map.author) do
        :error -> {@nul32, @nul32}
        %Terrasol.Author{privatekey: nil, publickey: pk} -> {@nul32, pk}
        %Terrasol.Author{privatekey: sk, publickey: pk} -> {sk, pk}
      end

    map |> compute_hash |> Ed25519.signature(priv, pub) |> Terrasol.bencode()
  end

  defp gather_fields(_, [], str), do: str

  defp gather_fields(doc, [f | rest], str) do
    case Map.fetch!(doc, f) do
      nil -> gather_fields(doc, rest, str)
      val -> gather_fields(doc, rest, str <> "#{f}\t#{val}\n")
    end
  end

  @doc """
  Parse and return a `Terrasol.Document.ES4` from a map.

  Returns `{:invalid, [error_field]}` on an invalid document
  """
  @impl Terrasol.Document.Format
  def parse(document)

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

  defp parse_fields(doc, [], []), do: doc
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

  defp parse_fields(doc, [f | rest], errs) when f == :deleteAfter do
    # Spec min int or after now from our perspective
    min_allowed = Enum.max([@min_ts, :erlang.system_time(:microsecond)])

    val = doc.deleteAfter

    ephem =
      case doc.path do
        %Terrasol.Path{ephemeral: val} -> val
        _ -> false
      end

    errlist =
      case {is_nil(val), ephem, not is_integer(val) or (val >= min_allowed and val <= @max_ts)} do
        {true, true, _} -> [:ephem_delete_mismatch | errs]
        {false, false, _} -> [:ephem_delete_mismatch | errs]
        {_, _, false} -> [f | errs]
        {_, _, true} -> errs
      end

    parse_fields(doc, rest, errlist)
  end

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

  defp parse_fields(doc, [f | rest], errs) when f == :contentHash do
    computed_hash = content_hash(doc)

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
