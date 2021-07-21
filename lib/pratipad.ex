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

    demand_config =
      if dataflow.mode == :pull do
        Application.fetch_env!(:pratipad, :demand)
      end

    {:ok, broadway} =
      DynamicSupervisor.start_child(Pratipad.Supervisor, {
        Pratipad.Broadway.Forward,
        build_broadway_config(dataflow.mode, :pratipad_forwarder_input, demand_config,
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
          build_broadway_config(:push, :pratipad_backwarder_input, nil,
            output_handler: output_handler
          )
        })

      %{
        broadway: broadway,
        output_handler: output_handler
      }
    end
  end

  defp build_broadway_config(dataflow_mode, receiver_name, demand_config, context) do
    producer_config = [
      module:
        {OffBroadwayOtpDistribution.Producer,
         [
           mode: dataflow_mode,
           receiver: [
             name: receiver_name
           ]
         ]}
    ]

    producer_config =
      if demand_config && demand_config[:rate_limiting] do
        producer_config ++ [rate_limiting: demand_config[:rate_limiting]]
      else
        producer_config
      end

    processors_config = [concurrency: 1]
    processors_config =
      if demand_config && demand_config[:count] do
        processors_config ++ demand_config[:count]
      else
        processors_config
      end

    config = [
      producer: producer_config,
      processors: [
        default: processors_config
      ],
      batchers: [
        default: [concurrency: 1]
      ],
      context: context
    ]

    Logger.debug(config)
    config
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
