defmodule Smalltoc.MixProject do
  use Mix.Project

  def project do
    [
      app:                    :smalltoc,
      version:                "0.1.0",
      elixir:                 "~> 1.9",
      start_permanent:        Mix.env() == :prod,
      deps:                   deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications:     [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :dialyxir,            github: "jeremyjh/dialyxir",
          only:               [:dev],
          runtime:            false
      },
      { :floki, override: true,
        git: "https://github.com/RichMorin/floki.git" },
    ]
  end
end
