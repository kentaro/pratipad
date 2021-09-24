# Pratipad

Pratipad is a declarative framework for describing bidirectional dataflow.

## Usage

### Dataflow

```elixir
defmodule Pratipad.Example.Dataflow do
  use Pratipad.Dataflow
  alias Pratipad.Dataflow.{Demand, Output}
  alias Pratipad.Example.Processor.Precipitation

  def declare() do
    Demand <~> Precipitation <~> Output
  end
end
```

### Processor

```elixir
defmodule Pratipad.Example.Processor.Precipitation do
  alias Pratipad.Processor
  use Processor

  @impl GenServer
  def init(opts \\ []) do
    {:ok, opts}
  end

  @impl Processor
  def process(data, state) do
    # do something with the message
  end
end
```

See the [example repository](https://github.com/kentaro/pratipad_example) for details.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pratipad` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pratipad, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pratipad](https://hexdocs.pm/pratipad).
