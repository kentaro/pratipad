defmodule Pratipad.Dataflow do
  defstruct [:input, :forward, :backward_enabled, :output]

  defmodule Forward do
    defstruct [:processors, :batcher]
  end

  defmacro __using__(opts \\ [behaviour: true]) do
    quote do
      if unquote(opts[:behaviour]) do
        @callback declare() :: Pratipad.Dataflow
        @behaviour Pratipad.Dataflow
      end

      alias Pratipad.Dataflow
      alias Pratipad.Dataflow.{Input, Output}

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
        [batcher | processors] =
          left.forward.processors
          |> Enum.reverse()

        %Dataflow{
          input: left.input,
          forward: %Forward{
            processors: processors |> Enum.reverse(),
            batcher: batcher
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
