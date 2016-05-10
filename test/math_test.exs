defmodule MathTest do
  use ExUnit.Case
  doctest Math

  test "make_vector returns vector" do
    a = {1, 2, 3}
    b = {2, 2, 2}
    v = Math.Vector.make_vector(a, b)
    assert v == {1, 0, -1}
  end

  test "make_vector raises on invalid arguments" do
    a = {1, 1, 1}
    b = {2, 2}
    
    try do 
      Math.Vector.make_vector(a, b)
      assert false
    rescue
      _ -> assert true
    end
  end

  test "vector_length returns correct length" do
    v = {1, 1, 1}
    l = Math.Vector.vector_length(v)
    assert l == 1.7320508075688772
  end

  test "vector_minus" do
    va = {3, 2, 1}
    vb = {1, 1, 1}

    v = Math.Vector.vector_minus(va, vb)
    assert v == {2, 1, 0}

    v = Math.Vector.vector_minus(vb, va)
    assert v == {-2, -1, 0}
  end

  test "point_on_vector" do
    pa = {1, 0, 0}
    pb = {0, 1, 0}
    p0 = {0, 0, 0}

    p = Math.Vector.point_on_vector(pa, pb, p0)
    assert p == {0.5, 0.5, 0}

    pa = {1, -1, 0}
    pb = {1, 1, 0}
    p0 = {0, 0, 0}

    p = Math.Vector.point_on_vector(pa, pb, p0)
    assert p == {1, 0, 0}

    pa = {1, -1, -1}
    pb = {1, 1, 1}
    p0 = {0, 0, 0}

    p = Math.Vector.point_on_vector(pa, pb, p0)
    assert p == {1, 0, 0}

    pa = {1, -1, -1}
    pb = {1, 1, 1}
    p0 = {1, 1, 0}

    p = Math.Vector.point_on_vector(pa, pb, p0)
    assert p == {1, 0.5, 0.5}

  end

  test "cross_product basic axioms" do
    va = {1, 0, 0}
    vb = {0, 1, 0}
    vc = {0, 0, 1}

    v = Math.Vector.cross_product(va, va)
    assert v == {0, 0, 0}

    v = Math.Vector.cross_product(vb, vb)
    assert v == {0, 0, 0}

    v = Math.Vector.cross_product(vc, vc)
    assert v == {0, 0, 0}

    v = Math.Vector.cross_product(va, vb)
    assert v == {0, 0, 1}

    v = Math.Vector.cross_product(vb, va)
    assert v == {0, 0, -1}

    v = Math.Vector.cross_product(va, vc)
    assert v == {0, -1, 0}

    v = Math.Vector.cross_product(vc, va)
    assert v == {0, 1, 0}

    v = Math.Vector.cross_product(vb, vc)
    assert v == {1, 0, 0}

    v = Math.Vector.cross_product(vc, vb)
    assert v == {-1, 0, 0}

  end

  test "distance_from_point" do
    pa = {-2, 2, 0}
    pb = {2, 2, 0}
    p0 = {0, 0, 0}

    d = Math.Vector.distance_from_point(pa, pb, p0)
    assert d == 2

    pa = {-2, 2, 0}
    pb = {2, 2, 2}
    p0 = {0, 0, 0}

    d = Math.Vector.distance_from_point(pa, pb, p0)
    assert d == 2.1908902300206643

    pa = {-2, -2, -2}
    pb = {2, 2, 2}
    p0 = {0, 0, 0}

    d = Math.Vector.distance_from_point(pa, pb, p0)
    assert d == 0
  end

  test "point_in_cube" do
    p0 = {0, 0, 0}
    p1 = {-1, -1, -1}
    p2 = {1, 1, 1}

    b = Math.Vector.point_in_cube(p1, p2, p0)
    assert b == true

    p0 = {-5932623.046990407, 1430338.1230178077, 1631787.9691492245}
    p1 = {484654.5547874758, -6061627.408215411, -1710671.9342397202}
    p2 = {-2723984.2461014646, -2315644.642598802, -39441.98254524823}
    b = Math.Vector.point_in_cube(p0, p1, p2)
    assert b == true
  end

  test "creating graph" do
    n = %{1 => {0, 1}, 2 => {2, 3}}
    e = %{1 => [{2, 3}], 2 => [{1, 3}]}
    
    g = Math.Graph.create
    assert Math.Graph.is_valid?(g) == false

    g = Math.Graph.set_nodes(g, n)
    assert Math.Graph.is_valid?(g) == false

    g = Math.Graph.set_edges(g, e)
    assert Math.Graph.is_valid?(g) == true

    g = Math.Graph.create
    g = Math.Graph.set_nodes(g, n)
    e = %{3 => [{2, 3}], 2 => [{1, 3}]}
    g = Math.Graph.set_edges(g, e)
    assert Math.Graph.is_valid?(g) == false

    g = Math.Graph.create
    g = Math.Graph.set_nodes(g, n)
    e = %{1 => [{2, 3}], 2 => [{3, 3}]}
    g = Math.Graph.set_edges(g, e)
    assert Math.Graph.is_valid?(g) == false
  end

  test "find shortest path" do
    n = %{1 => {0, 0}, 2 => {0, 1}, 3 => {0, 1}, 4 => {1, 1}}
    e = %{1 => [{2, 3430173.7339734887}, {4, 3286300.7220469345}], 
          2 => [{3, 1}, {1, 3430173.7339734887}, {4, 1246525.6506004534}], 
          3 => [{2, 1}], 
          4 => [{1, 3286300.7220469345}, {4, 1246525.6506004534}]}
    
    g = Math.Graph.create
    g = Math.Graph.set_nodes(g, n)
    g = Math.Graph.set_edges(g, e)

    p = Math.Graph.shortest_path(g, 1, 3)
    assert p == [1, 2, 3]
  end
end
