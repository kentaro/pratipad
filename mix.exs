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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 0.6.0"},
      {:off_broadway_otp_distribution, "~> 0.1.0",
       github: "kentaro/off_broadway_otp_distribution", branch: "main"}
    ]
  end
end
