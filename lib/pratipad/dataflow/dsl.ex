defmodule Pratipad.Dataflow.DSL do
  defmacro __using__(_opts) do
    quote do
      alias Pratipad.Dataflow
      alias Pratipad.Dataflow.{Push, Demand, Pull, Forward, Output}

      @input_mode_map %{
        Push => :push,
        Demand => :pull,
        Pull => :push
      }

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

      defp handle_unidirectional_op(left, right)
           when left == Push or left == Demand do
        %Dataflow{
          mode: @input_mode_map[left],
          forward: %Forward{
            processors: [right]
          },
          backward_enabled: false
        }
      end

      defp handle_unidirectional_op(left, right) when left == Pull do
        raise(ArgumentError, message: "pull mode can be enabled only for bidirectional dataflow")
      end

      defp handle_bidirectional_op(left, right) do
        if left == Pull do
          %Dataflow{
            mode: @input_mode_map[left],
            forward: %Forward{
              processors: [right]
            },
            backward_enabled: true
          }
        else
          handle_unidirectional_op(left, right)
          |> Map.put(:backward_enabled, true)
        end
      end

      defp handle_unidirectional_op(%Dataflow{} = left, Output = right) do
        %Dataflow{
          mode: left.mode,
          forward: %Forward{
            processors: left.forward.processors
          },
          backward_enabled: false
        }
      end

      defp handle_unidirectional_op(%Dataflow{} = left, right) do
        %Dataflow{
          mode: left.mode,
          forward: %Forward{
            processors: left.forward.processors ++ [right]
          },
          backward_enabled: false
        }
      end
    end
  end
end
