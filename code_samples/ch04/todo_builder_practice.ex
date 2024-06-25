defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  @spec new(list(%{date: Date, title: String.t()}) | []) :: TodoList

  def new(entries \\ []) do
    entries
    |> Enum.reduce(
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  @spec add_entry(
          todo_list :: TodoList,
          entry :: %{date: Date, title: String.t()}
        ) ::
          TodoList

  def add_entry(todo_list, entry = %{date: _, title: _}) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def add_entry(todo_list, entry) do
    IO.puts("Unexpected structure:")
    IO.inspect(entry)
    todo_list
  end

  @spec delete_entry(
          todo_list :: TodoList,
          entry_id :: integer()
        ) :: TodoList

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end

  @spec update_entry(
          todo_list :: TodoList,
          entry_id :: integer(),
          updater_fn :: (%{date: Date, title: String.t()} -> %{date: Date, title: String.t()})
        ) :: TodoList

  def update_entry(todo_list, entry_id, updater_fn) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end
end

defmodule TodoList.CsvImporter do
  @spec import(file_name :: String.t()) :: TodoList

  def import(file_name) do
    file_name
    |> read_lines!()
    |> create_entries!()
    |> TodoList.new()
  end

  defp read_lines!(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  defp create_entries!(lines) do
    lines
    |> Stream.map(fn line ->
      [date_string, title] = String.split(line, ",")
      date = Date.from_iso8601!(date_string)
      %{date: date, title: title}
    end)
  end
end
