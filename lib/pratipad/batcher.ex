defmodule Pratipad.Batcher do
  @callback process(messages :: term) :: messages :: term

  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias Broadway.Message

      @impl GenServer
      def init(_opts) do
        {:ok, nil}
      end

      def start_link(opts \\ []) do
        name = opts[:name] || __MODULE__
        GenServer.start_link(__MODULE__, opts, name: name)
      end

      @impl GenServer
      def handle_call({:process, messages}, _from, state) do
        messages = messages |> process()
        {:reply, messages, state}
      end
    end
  end
end
