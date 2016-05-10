
defmodule PriorityQueueTest do
  use ExUnit.Case

  test "basic tests" do
    q = PriorityQueue.create

    q = PriorityQueue.put(q, {1, "foo"})
    q = PriorityQueue.put(q, {3, "foobar"})
    q = PriorityQueue.put(q, {2, "bar"})

    {e, q} = PriorityQueue.pop(q)
    assert e == {1, "foo"}

    {e, q} = PriorityQueue.pop(q)
    assert e == {2, "bar"}

    {e, q} = PriorityQueue.pop(q)
    assert e == {3, "foobar"}

  end
end