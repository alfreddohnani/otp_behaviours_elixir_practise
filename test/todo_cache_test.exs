defmodule TodoCacheTest do
  alias DataStructures.GenServerTodoList
  alias DataStructures.TodoEntry
  alias DataStructures.TodoCache
  use ExUnit.Case

  test "server_process" do
    bob_pid = TodoCache.server_process("bob")
    alice_pid = TodoCache.server_process("alice")

    assert bob_pid != alice_pid
    assert bob_pid == TodoCache.server_process("bob")
  end

  test "todo operations" do
    # Delete DB files before running test

    alice = TodoCache.server_process("alice")
    GenServerTodoList.add_entry(alice, %TodoEntry{date: ~D[2023-12-19], title: "Dentist"})
    entries = GenServerTodoList.entries(alice, ~D[2023-12-19])
    assert [%TodoEntry{date: ~D[2023-12-19], title: "Dentist"}] = entries

    bob = TodoCache.server_process("bob")
    GenServerTodoList.add_entry(bob, %TodoEntry{date: ~D[2026-03-03], title: "Read a book"})

    assert [%TodoEntry{date: ~D[2026-03-03], title: "Read a book"}] =
             GenServerTodoList.entries(bob, ~D[2026-03-03])

    jane = TodoCache.server_process("jane")
    GenServerTodoList.add_entry(jane, %TodoEntry{date: ~D[2026-03-04], title: "Clean the room"})

    assert [%TodoEntry{date: ~D[2026-03-04], title: "Clean the room"}] =
             GenServerTodoList.entries(jane, ~D[2026-03-04])
  end
end
