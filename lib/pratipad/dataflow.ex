defmodule Pratipad.Dataflow do
  defstruct [:input, :forward, :backward_enabled, :output]

  defmodule Forward do
    defstruct [:processors, :batcher]
  end

  @type t :: %Pratipad.Dataflow{}
  @callback declare() :: t()

  defmacro __using__(_opts) do
    quote do
      use Pratipad.Dataflow.DSL
      @behaviour Pratipad.Dataflow
    end
  end
end
