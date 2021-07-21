defmodule Pratipad do
  @moduledoc """
  Documentation for `Pratipad`.
  """

  use GenServer
  require Logger

  @impl GenServer
  def init(_opts \\ []) do
    dataflow_module = Application.fetch_env!(:pratipad, :dataflow)

    dataflow = dataflow_module.declare()

    forward = start_broadway_for(:forward, dataflow)
    backward = start_broadway_for(:backward, dataflow)

    {:ok,
     %{
       dataflow: dataflow,
       forward: forward,
       backward: backward
     }}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  defp start_broadway_for(:forward, dataflow) do
    {:ok, message_handler} = start_message_handler(dataflow)
    {:ok, output_handler} = start_output_handler(name: :pratipad_forwarder_output)

    {:ok, broadway} =
      DynamicSupervisor.start_child(Pratipad.Supervisor, {
        Pratipad.Broadway.Forward,
        build_broadway_config(dataflow.mode, :pratipad_forwarder_input,
          message_handler: message_handler,
          output_handler: output_handler
        )
      })

    %{
      broadway: broadway,
      message_handler: message_handler,
      output_handler: output_handler
    }
  end

  defp start_broadway_for(:backward, dataflow) do
    if dataflow.backward_enabled do
      {:ok, output_handler} = start_output_handler(name: :pratipad_backwarder_output)

      {:ok, broadway} =
        DynamicSupervisor.start_child(Pratipad.Supervisor, {
          Pratipad.Broadway.Backward,
          build_broadway_config(dataflow.mode, :pratipad_backwarder_input, output_handler: output_handler)
        })

      %{
        broadway: broadway,
        output_handler: output_handler
      }
    end
  end

  defp build_broadway_config(dataflow_mode, receiver_name, context) do
    [
      producer: [
        module:
          {OffBroadwayOtpDistribution.Producer,
           [
             mode: dataflow_mode,
             receiver: [
               name: receiver_name
             ]
           ]}
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        default: [concurrency: 1]
      ],
      context: context
    ]
  end

  defp start_message_handler(dataflow) do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Handler.Message,
      dataflow: dataflow
    })
  end

  defp start_output_handler(opts) do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Handler.Output,
      opts
    })
  end
end
