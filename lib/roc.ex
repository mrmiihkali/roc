
defmodule Earth do
  @doc "Earth radius in meters"
  def radius do
    6317000.0
  end
end

defmodule ROC do

  def main(args) do
    try do
      {switches, file_name, _} = OptionParser.parse(args, switches: [hops: :boolean])
      file_name = hd(file_name)

      data = ROC.read_satellite_data(file_name)
      graph = ROC.create_graph(data, switches[:hops])
      IO.inspect ROC.route_call(graph)
    rescue
      e -> IO.inspect e; usage
    end
  end

  def usage do
    IO.puts "Usage: roc <file name> [--hops=true|false]"
    IO.puts "\n--hops  true(default) optimizes number of hops, false optimizes path length"
  end

  def route_call(graph) do
    Math.Graph.shortest_path(graph, "START", "END")
  end

  @doc "
    Reads satellite data from given file.

    File format is:
    1st line     : #SEED <random seed, float>
    2nd..nth line: <satellite name, string>,<lat, float>,<lon, float>,<alt(km), float>
    Last line    : ROUTE,<route start lat, float>,<route start lon, float>,<route end lat, float>,<route end lon, float>

    Returns tuple 
      :seed       : the random seed read from the file
      :route      : %{:start_lat, :start_lon, :end_lat, :end_lon}
      :satellites : list of %{:name, :lat, :lon, :alt, :x, :y, :z}
  "
  def read_satellite_data(file_name) do
    lines = file_name
      |> File.stream!
      |> Stream.map(&String.strip/1)
      |> Enum.to_list

    seed_line = List.first(lines)
    route_line = List.last(lines)
    lines = List.delete(lines, seed_line)
    lines = List.delete(lines, route_line)
    
    %{:seed => seed(seed_line), 
      :route => route(route_line),
      :satellites => satellites(lines)}
  end 

  def create_graph(from_data, optimize_hops) do
  
    nodes = %{"START" => {from_data.route.start_x, from_data.route.start_y, from_data.route.start_z},
              "END" => {from_data.route.end_x, from_data.route.end_y, from_data.route.end_z}}
    nodes = Enum.reduce(from_data.satellites, nodes, fn(s, nodes) -> 
      Map.merge(nodes, %{s.name => {s.x, s.y, s.z}})
    end)

    graph = Math.Graph.create

    graph = Math.Graph.set_nodes(graph, nodes)

    edges = %{}
    edges = Enum.reduce(nodes, edges, fn(n, edges) ->
      Map.merge(edges, %{elem(n, 0) => 
        Enum.reduce(nodes, [], fn(nn, l) ->
          pa = elem(n, 1)
          pb = elem(nn, 1)
          cond do
            nn == n -> l # No edge to self
            true ->
              p = Math.Vector.point_on_vector(pa, pb, {0, 0, 0})
              d = Math.Vector.vector_length(p)

              cond do
                # Earth blocks
                d < Earth.radius and Math.Vector.point_in_cube(pa, pb, p) -> l 
                # Use constant weights, optimize hops
                optimize_hops == true -> l ++ [ {elem(nn, 0), 1}]
                # Use distance as weight, optimize path length
                true -> l ++ [ {elem(nn, 0), Math.Vector.vector_length(pa, pb)}]
                
              end
          end 
        end)})
    end)
    
    Math.Graph.set_edges(graph, edges)
  end

  defp seed(line) do
    r = ~r/#SEED:*(?<seed>.*)/
    res = Regex.named_captures(r, line)
    String.to_float(String.strip(res["seed"]))
  end

  defp route(line) do
    r = ~r/ROUTE,(?<start_lat>.*),(?<start_lon>.*),(?<end_lat>.*),(?<end_lon>.*)/
    res = Regex.named_captures(r, line)

    {start_x, start_y, start_z} = Math.polar_to_cartesian(String.to_float(res["start_lat"]), 
                                                          String.to_float(res["start_lon"]), 
                                                          Earth.radius)

    {end_x, end_y, end_z} = Math.polar_to_cartesian(String.to_float(res["end_lat"]),
                                                    String.to_float(res["end_lon"]),
                                                    Earth.radius)

    %{:start_x => start_x, :start_y => start_y, :start_z => start_z,
      :end_x => end_x, :end_y => end_y, :end_z => end_z}
  end

  defp satellites(lines) do
    r = ~r/(?<name>.*),(?<lat>.*),(?<lon>.*),(?<alt>.*)/
    Enum.map(lines, 
              fn line -> 
                convert_satellite(Regex.named_captures(r, line)) 
              end)
  end

  defp convert_satellite(sat) do
    alt = Earth.radius + String.to_float(sat["alt"]) * 1000
    lat = String.to_float(sat["lat"])
    lon = String.to_float(sat["lon"])

    {x, y, z} = Math.polar_to_cartesian(lat, lon, alt)

    %{:name => sat["name"], :alt => alt, 
      :lat => lon, :lon => lon, 
      :x => x, :y => y, :z => z}
  end

end
