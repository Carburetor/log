defmodule Log.MixProject do
  use Mix.Project

  def project do
    [
      app: :log,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      consolidate_protocols: consolidate_protocols(Mix.env()),
      # Docs
      name: "Log",
      source_url: "https://github.com/rill-project/log",
      homepage_url: "https://github.com/rill-project/log",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, ">= 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.19.2", only: [:dev]}
    ]
  end

  def package do
    [
      maintainers: ["Francesco Belladonna"],
      description: "Log to console library, with configurable levels and tagging",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rill-project/log"},
      files: [
        ".formatter.exs",
        "mix.exs",
        "README.md",
        "test",
        "lib"
      ]
    ]
  end

  def docs do
    [
      main: "README.md",
      extras: ["README.md": [filename: "README.md", title: "Log"]]
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test"]
  def elixirc_paths(_), do: ["lib"]

  def consolidate_protocols(:test), do: false
  def consolidate_protocols(:dev), do: false
  def consolidate_protocols(_), do: true
end
