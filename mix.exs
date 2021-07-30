defmodule Terrasol.MixProject do
  use Mix.Project

  def project do
    [
      app: :terrasol,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ed25519, "~> 1.3"},
      {:equivalex, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~>  0.0", only: :dev}
    ]
  end
end
