defmodule Terrasol.Author do
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
  Create a `Terrsol.Author` from a `keypair.json`-style file
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
  Fill a %Terrasol.Author from a map or address string

  Conflict resolution is determinisitic, but depends on implementation
  specific ordering which is not gauranteed and should not be depended
  upon being the same between versions.

  :error on invalid input
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
          %{full | publickey: rpk}
          |> Map.put(
            :string,
            "@" <> short <> "." <> bpk
          )
        )
    end
  end

  def build(%{privatekey: sk} = full) do
    case proper_keys(sk) do
      :error ->
        :error

      {rsk, _} ->
        build(%{full | privatekey: rsk} |> Map.put(:publickey, Ed25519.derive_public_key(rsk)))
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

  def build(input) when is_map(input), do: build(%{shortname: build_random_sn([])})

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
  Parse an author address into a Terrasol.Author

  :error on invalid input
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

  defp checknamelist([h | t], acc) when h in 97..122 or h in 48..57,
    do: checknamelist(t, [h | acc])

  defp checknamelist([], acc) when length(acc) == 4, do: acc |> Enum.reverse() |> to_string
  defp checknamelist(_, _), do: :error
end
