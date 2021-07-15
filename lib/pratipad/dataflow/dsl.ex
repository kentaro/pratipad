defmodule Pratipad.Dataflow.DSL do
  defmacro __using__(_opts) do
    quote do
      alias Pratipad.Dataflow
      alias Pratipad.Dataflow.{Input, Output, Forward}

      defmacro left ~> right do
        quote do
          handle_unidirectional_op(unquote(left), unquote(right))
        end
      end

      defmacro left <~> right do
        quote do
          handle_bidirectional_op(unquote(left), unquote(right))
        end
      end

      defp handle_unidirectional_op(Input = left, right) do
        %Dataflow{
          input: left,
          forward: %Forward{
            processors: [right]
          },
          backward_enabled: false
        }
      end

      defp handle_bidirectional_op(left, right) do
        handle_unidirectional_op(left, right)
        |> Map.put(:backward_enabled, true)
      end

      defp handle_unidirectional_op(%Dataflow{input: Input} = left, Output = right) do
        %Dataflow{
          input: left.input,
          forward: %Forward{
            processors: left.forward.processors
          },
          backward_enabled: false,
          output: right
        }
      end

      defp handle_unidirectional_op(%Dataflow{input: Input} = left, right) do
        %Dataflow{
          input: left.input,
          forward: %Forward{
            processors: left.forward.processors ++ [right]
          },
          backward_enabled: false
        }
      end
    end
  end
end
