defmodule MyTodo.Server do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  @impl GenServer
  def init(_init_arg) do
    {:ok, MyTodo.List.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = MyTodo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, todo_list) do
    {:reply, MyTodo.List.entries(todo_list, date), todo_list}
  end

  @impl GenServer
  def handle_info(msg, todo_list) do
    IO.puts("Unknown message:")
    IO.inspect(msg)
    {:noreply, todo_list}
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  @spec entries(pid :: GenServer.server(), date :: Date) :: any()
  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
end
