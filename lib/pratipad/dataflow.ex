defmodule Pratipad.Dataflow do
  defstruct [:mode, :forward, :backward_enabled]

  defmodule Forward do
    defstruct [:processors]
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
