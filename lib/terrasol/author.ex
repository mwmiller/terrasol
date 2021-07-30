defmodule Terrasol.Author do
  @moduledoc """
  Handling of Earthstar author strings and resulting 
  Terrasol.Author.t structures
  """
  @enforce_keys [
    :string,
    :shortname,
    :publickey
  ]
  defstruct string: "",
            shortname: "",
            publickey: "",
            privatekey: nil

  @typedoc "An Earthstar author"
  @type t() :: %__MODULE__{
          string: String.t(),
          shortname: String.t(),
          publickey: binary,
          privatekey: nil | binary
        }
  defimpl String.Chars, for: Terrasol.Author do
    def to_string(author), do: "#{author.string}"
  end

  @doc """
  Create a `Terrsol.Author` structure from a `keypair.json`-style file

  `:error` on error
  """
  def from_keypair_file(filename) do
    try do
      %{"address" => string, "secret" => privatekey} = filename |> File.read!() |> Jason.decode!()

      case Terrasol.bdecode(privatekey) do
        :error -> :error
        pk -> build(%{string: string, privatekey: pk})
      end
    rescue
      _ -> :error
    end
  end

  @doc """
  Write a `keypair.json`-style file from a supplied identity.
  As a secret file, the `publickey` must be included.
  """
  def to_keypair_file(author, filename)

  def to_keypair_file(%Terrasol.Author{privatekey: secret, string: address} = author, filename) do
    try do
      content = %{"address" => address, "secret" => Terrasol.bencode(secret)} |> Jason.encode!()

      File.write!(filename, content)
      File.chmod(filename, 0o600)
      author
    rescue
      _ -> :error
    end
  end

  def to_keypair_file(_, _), do: :error

  @doc """
  Fill a `Terrasol.Author` structure from an address string or
  (possibly incomplete) map.

  Internal conflict resolution is determinisitic, but depends on
  implementation-specific ordering which is not gauranteed and should
  not be depended upon being the same between versions.

  `:error` on invalid input
  """
  def build(input)
  def build(%Terrasol.Author{} = input), do: input
  def build(input) when is_binary(input) and byte_size(input) == 59, do: parse(input)

  def build(input) when is_binary(input) do
    try do
      input
      |> Jason.decode!(keys: :atoms!)
      |> build
    rescue
      _ -> :error
    end
  end

  def build(%{string: string, privatekey: pk}) do
    most = parse(string)

    case proper_keys(pk) do
      {raw, _} -> %__MODULE__{most | privatekey: raw}
      :error -> :error
    end
  end

  def build(%{string: string}), do: string |> parse |> build()

  # Non-string containing versions
  def build(%{shortname: sn, publickey: pk, privatekey: sk} = full) do
    case {proper_keys(pk), proper_keys(sk), verifyname(sn)} do
      {:error, _, _} ->
        build(Map.delete(full, :publickey))

      {_, :error, _} ->
        build(Map.delete(full, :privatekey))

      {_, _, :error} ->
        build(Map.delete(full, :shortname))

      {{rpk, bpk}, {rsk, _}, short} ->
        %__MODULE__{
          shortname: short,
          publickey: rpk,
          privatekey: rsk,
          string: "@" <> short <> "." <> bpk
        }
    end
  end

  def build(%{shortname: sn, publickey: pk} = full) do
    case {proper_keys(pk), verifyname(sn)} do
      {:error, _} ->
        build(Map.delete(full, :publickey))

      {_, :error} ->
        build(Map.delete(full, :shortname))

      {{rpk, bpk}, short} ->
        struct(
          __MODULE__,
          %{full | publickey: rpk} |> Map.put(:string, "@" <> short <> "." <> bpk)
        )
    end
  end

  def build(%{shortname: sn, privatekey: sk} = full) do
    case {proper_keys(sk), verifyname(sn)} do
      {:error, _} ->
        build(Map.delete(full, :privatekey))

      {_, :error} ->
        build(Map.delete(full, :shortname))

      {{rsk, _bsk}, short} ->
        {rpk, bpk} = rsk |> Ed25519.derive_public_key() |> proper_keys

        struct(
          __MODULE__,
          %{full | privatekey: rsk}
          |> Map.put(:publickey, rpk)
          |> Map.put(:string, "@" <> short <> "." <> bpk)
        )
    end
  end

  def build(%{shortname: sn} = full) do
    case verifyname(sn) do
      :error ->
        build(%{})

      ^sn ->
        {rsk, rpk} = Ed25519.generate_key_pair()
        build(full |> Map.put(:publickey, rpk) |> Map.put(:privatekey, rsk))
    end
  end

  def build(input) when is_map(input),
    do: build(input |> Map.put(:shortname, build_random_sn([])))

  @snfirst 'abcdefghijklmnopqrstuvwxyz'
  @snok @snfirst ++ '1234567890'
  defp build_random_sn(list) when length(list) == 4, do: list |> Enum.reverse() |> to_string

  defp build_random_sn([]) do
    build_random_sn([Enum.random(@snfirst)])
  end

  defp build_random_sn(list) do
    build_random_sn([Enum.random(@snok) | list])
  end

  defp proper_keys(key) when is_binary(key) do
    case byte_size(key) do
      32 -> {key, Terrasol.bencode(key)}
      53 -> {Terrasol.bdecode(key), key}
      _ -> :error
    end
  end

  @doc """
  Parse an author address into a `Terrasol.Author`

  `:error` on invalid input
  """

  def parse(address)

  def parse(%Terrasol.Author{} = author), do: author

  def parse(<<"@", name::binary-size(4), ".b", encpub::binary-size(52)>> = string) do
    case {verifyname(name), Terrasol.bdecode("b" <> encpub)} do
      {_, :error} -> :error
      {:error, _} -> :error
      {shortname, key} -> %Terrasol.Author{string: string, shortname: shortname, publickey: key}
    end
  end

  def parse(_), do: :error

  defp verifyname(string), do: checknamelist(to_charlist(string), [])
  defp checknamelist([f | rest], []) when f in 97..122, do: checknamelist(rest, [f])
  defp checknamelist(_, []), do: :error

  defp checknamelist([h | t], acc) when h in 97..122 or h in 48..57,
    do: checknamelist(t, [h | acc])

  defp checknamelist([], acc) when length(acc) == 4, do: acc |> Enum.reverse() |> to_string
  defp checknamelist(_, _), do: :error
end
