defmodule Pratipad.Dataflow do
  @callback declare() :: Pratipad.Dataflow

  defstruct [:input, :forward, :backward, :output]

  defmodule Forward do
    defstruct [:processors]
  end

  defmodule Backward do
    defstruct [:processors]
  end

  defmacro __using__(_opts) do
    quote do
      alias Pratipad.Dataflow
      alias Pratipad.Dataflow.{Input, Output}

      @behaviour Pratipad.Dataflow

      defmacro left ~> right do
        quote do
          handle_unidirectional_op(unquote(left), unquote(right))
        end
      end

      defp handle_unidirectional_op(Input = left, right) do
        %Dataflow{
          input: left,
          forward: %Forward{
            processors: [right]
          }
        }
      end

      defp handle_unidirectional_op(%Dataflow{input: Input} = left, Output = right) do
        %Dataflow{
          input: left.input,
          forward: %Forward{
            processors: left.forward.processors,
          },
          output: right
        }
      end

      defp handle_unidirectional_op(%Dataflow{input: Input} = left, right) do
        %Dataflow{
          input: left.input,
          forward: %Forward{
            processors: [left.forward.processors ++ right]
          },
        }
      end
    end
  end
end
