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
end
