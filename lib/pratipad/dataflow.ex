defmodule Pratipad.Dataflow do
  @callback declare() :: Pratipad.Dataflow

  defstruct [:input, :processors, :output]

  defmacro __using__(_opts) do
    quote do
      alias Pratipad.Dataflow
      alias Pratipad.Dataflow.{Input, Output}

      @behaviour Pratipad.Dataflow

      defmacro left ~> right do
        quote do
          handle_flow_op(unquote(left), unquote(right))
        end
      end

      defp handle_flow_op(Input = left, right) do
        %Dataflow{
          input: left,
          processors: [right]
        }
      end

      defp handle_flow_op(%Dataflow{input: Input} = left, Output = right) do
        %Dataflow{
            input: left.input,
            processors: left.processors,
            output: right
          }
      end

      defp handle_flow_op(%Dataflow{input: Input} = left, right) do
        %Dataflow{
          input: left.input,
          processors: [left.processors ++ right]
        }
      end
    end
  end
end
