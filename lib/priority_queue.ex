
defmodule PriorityQueue do
  @moduledoc "Not the most efficient priority queue implementation..."
  
  def create do
    []
  end

  def put(queue, e) do
    i = Enum.reduce(queue, 0, fn(t, i) ->
      cond do
        elem(e, 0) < elem(t, 0) -> i
        true -> i + 1 
      end
    end)

    List.insert_at(queue, i, e)
  end

  def pop(queue) do
    e = hd(queue)
    {e, tl(queue)}
  end

  def is_empty?(queue) do
    queue == []
  end
end