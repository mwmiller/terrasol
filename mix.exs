defmodule Terrasol.MixProject do
  use Mix.Project

  def project do
    [
      app: :terrasol,
      version: "2.0.1",
      elixir: "~> 1.12",
      name: "Terrasol",
      source_url: "https://github.com/mwmiller/terrasol",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ed25519, "~> 1.3"},
      {:equivalex, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~>  0.0", only: :dev}
    ]
  end

  defp description do
    """
    Terrasol - a pure Elixir library for handling Earthstar data
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Matt Miller"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/mwmiller/terrasol",
        "Earthstar" => "https://earthstar-docs.netlify.app/"
      }
    ]
  end
end
