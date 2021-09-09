defmodule Pratipad.Handler.Message.Test do
  use ExUnit.Case, async: true
  use Pratipad.Dataflow.DSL
  alias Pratipad.Dataflow.{Push, Output}

  defmodule Add1 do
    use Pratipad.Processor

    @impl GenServer
    def init(opts) do
      {:ok, opts}
    end

    @impl Pratipad.Processor
    def process(data, _state) do
      data + 1
    end
  end

  test "simple" do
    dataflow = Push ~> Add1 ~> Output
    {:ok, handler} = Pratipad.Handler.Message.start_link(dataflow: dataflow)

    message = %Broadway.Message{data: 0, acknowledger: nil}
    processed = GenServer.call(handler, {:process, message})

    assert processed.data == 1
  end
end
