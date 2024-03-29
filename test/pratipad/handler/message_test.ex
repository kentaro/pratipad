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

  defmodule Add2 do
    use Pratipad.Processor

    @impl GenServer
    def init(opts) do
      {:ok, opts}
    end

    @impl Pratipad.Processor
    def process(data, _state) do
      data + 2
    end
  end

  defmodule Add3 do
    use Pratipad.Processor

    @impl GenServer
    def init(opts) do
      {:ok, opts}
    end

    @impl Pratipad.Processor
    def process(data, _state) do
      data + 3
    end
  end

  defmodule Add4 do
    use Pratipad.Processor

    @impl GenServer
    def init(opts) do
      {:ok, opts}
    end

    @impl Pratipad.Processor
    def process(data, _state) do
      data + 4
    end
  end

  test "it can handle a dataflow with a single processor" do
    dataflow = Push ~> Add1 ~> Output
    {:ok, handler} = Pratipad.Handler.Message.start_link(dataflow: dataflow)

    message = %Broadway.Message{data: 0, acknowledger: nil}
    processed = GenServer.call(handler, {:process, message})

    assert processed.data == 1
  end

  test "it can handle a dataflow with multiple processors" do
    dataflow = Push ~> Add1 ~> Add2 ~> Output
    {:ok, handler} = Pratipad.Handler.Message.start_link(dataflow: dataflow)

    message = %Broadway.Message{data: 0, acknowledger: nil}
    processed = GenServer.call(handler, {:process, message})

    assert processed.data == 3
  end

  test "it can handle a dataflow with sequential processors" do
    dataflow = Push ~> [Add1, Add2] ~> Output
    {:ok, handler} = Pratipad.Handler.Message.start_link(dataflow: dataflow)

    message = %Broadway.Message{data: 0, acknowledger: nil}
    processed = GenServer.call(handler, {:process, message})

    assert processed.data == 3
  end

  test "it can handle a dataflow with parallel processors" do
    dataflow = Push ~> {Add1, Add2} ~> Output
    {:ok, handler} = Pratipad.Handler.Message.start_link(dataflow: dataflow)

    message = %Broadway.Message{data: 0, acknowledger: nil}
    processed = GenServer.call(handler, {:process, message})

    assert processed.data == 0
  end

  test "it can handle a dataflow with a conbination of sequencial and parallel processors" do
    dataflow = Push ~> [Add1, Add2] ~> {Add3, Add4} ~> Output
    {:ok, handler} = Pratipad.Handler.Message.start_link(dataflow: dataflow)

    message = %Broadway.Message{data: 0, acknowledger: nil}
    processed = GenServer.call(handler, {:process, message})

    assert processed.data == 3
  end

  test "it can handle a dataflow with a conbination of parallel and sequencial processors" do
    dataflow = Push ~> {Add1, Add2} ~> [Add3, Add4] ~> Output
    {:ok, handler} = Pratipad.Handler.Message.start_link(dataflow: dataflow)

    message = %Broadway.Message{data: 0, acknowledger: nil}
    processed = GenServer.call(handler, {:process, message})

    assert processed.data == 7
  end
end
