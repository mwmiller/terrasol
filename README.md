# Terrasol

A pure Elixir implementation of [Earthstar](https://earthstar-docs.netlify.app/)
document handling.

At present this library only handles `es.4` formatted documents.  It may support 
newer formats as they become available.

## Generating new documents from minimal info

```
iex> trsl = Terrasol.Author.build(%{shortname: "trsl"})
%Terrasol.Author{
  privatekey: <<248, 130, 46, 164, 156, 41, 23, 192, 20, 134, 72, 53, 75, 105,
    253, 122, 36, 133, 206, 166, 250, 133, 36, 128, 103, 118, 75, 199, 45, 93,
    90, 234>>,
  publickey: <<102, 157, 164, 194, 41, 11, 242, 116, 195, 126, 1, 227, 25, 242,
    182, 22, 89, 34, 92, 6, 226, 177, 11, 199, 74, 32, 20, 130, 112, 211, 150,
    128>>,
  shortname: "trsl",
  string: "@trsl.bm2o2jqrjbpzhjq36ahrrt4vwczmsexag4kyqxr2keakie4gts2aa"
}
iex> Terrasol.Document.build(%{author: trsl, content: "An example for the README."})
%Terrasol.Document{
  author: %Terrasol.Author{
    privatekey: <<248, 130, 46, 164, 156, 41, 23, 192, 20, 134, 72, 53, 75, 105,
      253, 122, 36, 133, 206, 166, 250, 133, 36, 128, 103, 118, 75, 199, 45, 93,
      90, 234>>,
    publickey: <<102, 157, 164, 194, 41, 11, 242, 116, 195, 126, 1, 227, 25,
      242, 182, 22, 89, 34, 92, 6, 226, 177, 11, 199, 74, 32, 20, 130, 112, 211,
      150, 128>>,
    shortname: "trsl",
    string: "@trsl.bm2o2jqrjbpzhjq36ahrrt4vwczmsexag4kyqxr2keakie4gts2aa"
  },
  content: "An example for the README.",
  contentHash: "b4swex3c7g67sk4g6d3my5nzlcjpwjihwdjynxy36v36uss3z4vxq",
  deleteAfter: nil,
  format: "es.4",
  path: %Terrasol.Path{
    ephemeral: false,
    segments: ["terrasol", "scratch", "default.txt"],
    string: "/terrasol/scratch/default.txt",
    writers: []
  },
  signature: "blwphvnlgnyoup4jqgipq3cgidmvvfercrahiflwev47otbvivkzwmuzqqs36znhec4qe7k5xpeoztu2kjewa3qmpgxdupghwwfe7qby",
  timestamp: 1627671914037941, 
  workspace: %Terrasol.Workspace{
    name: "terrasol",
    string: "+terrasol.scratch",
    suffix: "scratch"
  }
}
```

The latest version should be [available in Hex](https://hex.pm/packages/terrasol).
