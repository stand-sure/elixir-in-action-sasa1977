defmodule ServerProcess do
  @doc """
  callback_module must export:
  init/0
  handle_call/2, handle_call(message, state)
  """
  @spec start(callback_module :: module()) :: pid()
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  @spec loop(callback_module :: module(), current_state :: any()) :: no_return()
  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)

        send(caller, {:response, response})
        loop(callback_module, new_state)
    end
  end

  @spec call(server_pid :: pid(), request :: any()) :: any()
  def call(server_pid, request) do
    send(server_pid, {request, self()})

    receive do
      {:response, response} ->
        response
    end
  end
end

defmodule KeyValueStore do
  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.call(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def init do
    %{}
  end

  @type put_call :: {:put, key :: any(), value :: any()}
  @type get_call :: {:get, key :: any()}
  @spec handle_call(message :: put_call() | get_call() | any(), state :: any()) :: any()

  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end

  def handle_call(unknown_message, state) do
    {{:error, IO.inspect(unknown_message)}, state}
  end
end
