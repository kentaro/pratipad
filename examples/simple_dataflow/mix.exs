defmodule SimpleDataflow.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_dataflow,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SimpleDataflow.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:pratipad, path: "../../", override: true},
      {:off_broadway_otp_distribution, "~> 0.1.0",
       github: "kentaro/off_broadway_otp_distribution", branch: "main"}
    ]
  end
end
