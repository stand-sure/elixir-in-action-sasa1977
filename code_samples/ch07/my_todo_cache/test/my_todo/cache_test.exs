defmodule MyTodo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = MyTodo.Cache.start()

    bob_pid = MyTodo.Cache.server_process(cache, "bob")

    assert bob_pid != MyTodo.Cache.server_process(cache, "alice")
    assert bob_pid == MyTodo.Cache.server_process(cache, "bob")
  end

  test "todo operations" do
    date = Date.utc_today()
    title = random_string()
    todo_list_name = random_string()

    {:ok, cache} = MyTodo.Cache.start()
    pid = MyTodo.Cache.server_process(cache, todo_list_name)

    MyTodo.Server.add_entry(pid, %{date: date, title: title})

    entries = MyTodo.Server.entries(pid, date)
    assert [%{date: ^date, title: ^title}] = entries
  end

  defp random_string() do
    for _ <- 1..10, into: "", do: <<Enum.random('0123456789abcdef')>>
  end
end
