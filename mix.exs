defmodule Pratipad.MixProject do
  use Mix.Project

  def project do
    [
      app: :pratipad,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Pratipad.Application, []},
      registered: [
        :pratipad_forwarder_input,
        :pratipad_forwarder_output,
        :pratipad_backwarder_input,
        :pratipad_backwarder_output
      ],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 1.0"}
    ]
  end
end
