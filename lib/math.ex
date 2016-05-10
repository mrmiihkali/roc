defmodule Math do
  @moduledoc "Some basic math functions."
  def deg_to_rad(deg) do
    deg * (:math.pi / 180)
  end

  def polar_to_cartesian(lat, lon, alt) do
    x = alt * :math.cos(Math.deg_to_rad(lat)) * :math.sin(Math.deg_to_rad(lon))
    y = alt * :math.sin(Math.deg_to_rad(lat))
    z = alt * :math.cos(Math.deg_to_rad(lat)) * :math.cos(Math.deg_to_rad(lon))

    {x, y, z}
  end

  defmodule Vector do
    @moduledoc "Vector math"

    def cross_product(va, vb) when
      tuple_size(va) == 3 and tuple_size(vb) == 3 do
      
      xa = elem(va, 1) * elem(vb, 2)
      xb = elem(va, 2) * elem(vb, 1)
      x = xa - xb

      ya = elem(va, 2) * elem(vb, 0)
      yb = elem(va, 0) * elem(vb, 2)
      y = ya - yb

      za = elem(va, 0) * elem(vb, 1)
      zb = elem(va, 1) * elem(vb, 0)
      z = za - zb

      {x, y, z}
    end

    @doc "Snipped the calculus from internet..."
    def point_on_vector(pa, pb, p0) when 
      tuple_size(pa) == 3 and tuple_size(pb) == 3 and tuple_size(p0) == 3 do

      y = make_vector(pa, pb)
      u = vector_minus(pa, p0);
      a = elem(y, 0)
      b = elem(y, 1)
      c = elem(y, 2)
      d = elem(u, 0)
      e = elem(u, 1)
      f = elem(u, 2)

      t = -(a*d+b*e+c*f)/(a*a+b*b+c*c)

      {elem(pa, 0) + t * a,
       elem(pa, 1) + t * b,
       elem(pa, 2) + t * c}
    end

    @doc "Returns shortest distance between line pa -> pb and p0. 
    Points are tuples {x, y, z}."
    def distance_from_point(pa, pb, p0) when
      tuple_size(pa) == 3 and tuple_size(pb) == 3 and tuple_size(p0) == 3 do

      vab = make_vector(pa, pb)
      va0 = make_vector(pa, p0)
      cp = cross_product(va0, vab)

      cond do
        cp == {0, 0, 0} ->
          cond do
            point_in_cube(pa, pb, p0) -> 0
            true -> min(vector_length(p0, pa), vector_length(p0, pb))            
          end
        true -> vector_length(cp) / vector_length(vab)
      end
    end

    def point_in_cube(pa, pb, p0) when
      tuple_size(pa) == 3 and tuple_size(pb) == 3 and tuple_size(p0) == 3 do

      mins = iterate_elements(pa, pb, &min/2)
      maxs = iterate_elements(pa, pb, &max/2)

      mins2 = iterate_elements(mins, p0, &min/2)
      maxs2 = iterate_elements(maxs, p0, &max/2)

      lesser = mins == mins2
      greater = maxs == maxs2

      lesser and greater
    end

    defp iterate_elements(va, vb, action) do
      iterate_elements(va, vb, [], action)
    end

    defp iterate_elements({}, {}, vector, _) do
      List.to_tuple(vector)
    end

    defp iterate_elements(va, vb, vector, action) do
      iterate_elements(Tuple.delete_at(va, 0), 
                       Tuple.delete_at(vb, 0), 
                       vector ++ [action.(elem(va, 0), elem(vb, 0))],
                       action)
    end

    @doc "Returns vector from point A to point B"
    def make_vector(pa, pb)  when
      tuple_size(pa) == tuple_size(pb) do

      iterate_elements(pa, pb, fn(a, b) -> b - a end)
    end

    def vector_minus(va, vb) when
      tuple_size(va) == tuple_size(vb) do

      iterate_elements(va, vb, fn(a, b) -> a - b end)
    end

    def vector_plus(va, vb) when
      tuple_size(va) == tuple_size(vb) do

      iterate_elements(va, vb, fn(a, b) -> a + b end)
    end

    def vector_length(pa, pb) do
      make_vector(pa, pb) |> 
      vector_length
    end

    def vector_length(vector) do
      sqrsum = Enum.reduce(Tuple.to_list(vector), 0, fn(x, sqrsum) -> x * x + sqrsum end)
      :math.sqrt(sqrsum)
    end

  end

  defmodule Graph do
    @moduledoc "Graph is %{nodes: %{id: <node>}, edges: %{id: [<edge>]}}, node is {x, y, z}, edge is {to_id, weight}"

    def create do
      %{}
    end

    def set_nodes(graph, nodes) do
      Map.merge(graph, %{nodes: nodes})
    end

    def set_edges(graph, edges) do
      Map.merge(graph, %{edges: edges})
    end

    @doc "Check nodes and edges match."
    def is_valid?(graph) do
      cond do
        Map.has_key?(graph, :nodes) == false -> false
        Map.has_key?(graph, :edges) == false -> false
        true -> Enum.reduce(graph.edges, true, fn(t, b) -> 
          b and 
          # Check from id is in nodes
          Map.has_key?(graph.nodes, elem(t, 0)) and
          # Check all to_ids are in nodes
          Enum.reduce(elem(t, 1), true, fn(t, b) ->
            b and 
            Map.has_key?(graph.nodes, elem(t, 0)) end)
        end)
      end
    end

    @doc "Find shortes path from start_node to end_node using Dijkstra." 
    def shortest_path(graph, start_node, end_node) do
      q = PriorityQueue.create
      q = PriorityQueue.put(q, {0, start_node})
      shortest_path(graph, end_node, q, %{start_node => nil})
    end

    defp shortest_path(graph, end_node, paths, visited) do
      {node, paths} = PriorityQueue.pop(paths)

      path_weight = elem(node, 0)
      current_node = elem(node, 1)

      {paths, visited} = Enum.reduce(graph.edges[current_node], {paths, visited}, fn(e, p) ->
        paths = elem(p, 0)
        visited = elem(p, 1)
        to_node = elem(e, 0)
        weight = elem(e, 1)

        cond do
          Map.has_key?(visited, to_node) -> p
          true -> 
            paths = PriorityQueue.put(paths, {path_weight + weight, to_node});
            visited = Map.merge(visited, %{to_node => current_node})
            {paths, visited} 
        end
      end)

      cond do
        current_node == end_node -> compile_path(current_node, [], visited)
        PriorityQueue.is_empty?(paths) -> []
        true -> shortest_path(graph, end_node, paths, visited)
      end
    end

    defp compile_path(nil, path, _) do
      Enum.reverse(path)
    end

    defp compile_path(node, path, visited) do
      prev = visited[node]
      path = path ++ [node]
      compile_path(prev, path, visited)
    end

  end
end
