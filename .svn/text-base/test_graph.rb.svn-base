require 'test/unit'
require 'graph.rb'

=begin

  Unit tests for the Graph class.

  @author Timur Reziapov <reziapo1@illinois.edu>
  @date Sunday, September 31, 2012 15:00 PM

=end

class GraphTest < Test::Unit::TestCase
  
  #* Check that parsing functions return false on illegal files
  def test_illegal_file_parsing
    assert_equal( Graph.new().parse_json_file("non_existstent.json"), false ) 
  end
  
  
  #* Checks that parsing functions return false on illegal strings
  def test_illegal_string_parsing
    
    bad_json = 'not even close to legal json format'
    assert_equal( Graph.new().parse_json_string(bad_json), false )
    
    valid_not_csair_json = ' { "some_key" : [ {"bla" : "bla" } ] } '
    assert_equal( Graph.new().parse_json_string(valid_not_csair_json), false )
    
    no_routes_key_json = ' {  "metros" : [ {
                                          "code" : "SCL" ,
                                          "name" : "Santiago" ,
                                          "country" : "CL" ,
                                          "continent" : "South America" ,
                                          "timezone" : -4 ,
                                          "coordinates" : {"S" : 33, "W" : 71} ,
                                          "population" : 6000000 ,
                                          "region" : 1
                                          } ] } ' 
    assert_equal( Graph.new().parse_json_string(no_routes_key_json), false ) 
    
    no_metros_key_json = ' { "routes" : [ { "ports" : ["SCL" , "LIM"],
                                            "distance" : 2453 } ] } '
    assert_equal( Graph.new().parse_json_string(no_metros_key_json), false )
    
  end
  
  
  #* Check that parsing functions work correctly on the CS Air file
  def test_legal_file_parsing
    assert_equal( Graph.new().parse_json_file("CSAirData.json"), true ) 
  end
  
  
  #* Check that parsing functions return true on legal json strings
  def test_legal_string_parsing
    
    valid_json = ' { "metros" : [ {
                                    "code" : "LON" ,
                                    "name" : "London" ,
                                    "country" : "UK" ,
                                    "continent" : "Europe" ,
                                    "timezone" : 0 ,
                                    "coordinates" : {"N" : 52, "W" : 0} ,
                                    "population" : 12400000 ,
                                    "region" : 3
                                  } , {
                                    "code" : "PAR" ,
                                    "name" : "Paris" ,
                                    "country" : "FR" ,
                                    "continent" : "Europe" ,
                                    "timezone" : 1 ,
                                    "coordinates" : {"N" : 49, "E" : 2} ,
                                    "population" : 10400000 ,
                                    "region" : 3
                                  } ] , 
                     "routes" : [ {
                                    "ports" : ["LON" , "PAR"] ,
                                    "distance" : 2410
                                  } ] } '
    assert_equal( Graph.new().parse_json_string(valid_json), true ) 

    missing_route_key = ' { "metros" : [ {
                                        "code" : "LON" ,
                                        "name" : "London",
                                        "country" : "X" ,
                                        "continent" : "X" ,
                                        "timezone" : 1 ,
                                        "coordinates" : {"N" : 1, "E" : 1} ,
                                        "population" : 1,
                                        "region" : 1
                                      } , {
                                        "code" : "MOW" ,
                                        "name" : "Moscow" ,
                                        "country" : "X" ,
                                        "continent" : "X" ,
                                        "timezone" : 1 ,
                                        "coordinates" : {"N" : 1, "E" : 1} ,
                                        "population" : 1,
                                        "region" : 1
                                      } ] ,
                             "routes" : [ {
                                        "ports" : ["LON" , "MOW"]
                                      } ] } '

      caught = false
      begin
        graph = Graph.new()
        graph.parse_json_string(missing_route_key)
      rescue
        caught = true
      end

      assert_equal( caught, true)

  end
  
  
  #* Check that a new node can be added to the graph storing all its information
  def test_adding_node
    
    # Start a new graph with no nodes
    graph = Graph.new()
    
    new_vertex = {  "code" => "NYC" ,
                    "name" => "New York" ,
                    "country" => "US" ,
                    "continent" => "North America" ,
                    "timezone" => -5 ,
                    "coordinates" => { "N" => 41, "W" => 74 } ,
                    "population" => 22200000 ,
                    "region" => 3 }
    graph.add_node(new_vertex)
    
    assert_equal( graph.nodes().size, 1)
    assert_equal( graph.nodes().has_key?("NYC"), true )
    assert_not_nil( graph.nodes["NYC"] )
    assert_equal( graph.nodes["NYC"].region, 3)
    assert_equal( graph.nodes["NYC"].coordinates["N"], 41)

    # Test adding illegal node
    bad_vertex = { "useless" => "information"}

    caught = false
    begin
      graph.add_node(bad_vertex)
    rescue
      caught = true
    end

    assert_equal( caught, true )

    missing_keys_vertex = { "code" => "A"}

      caught = false
    begin
      graph.add_node(bad_vertex)
    rescue
      caught = true
    end    
      
    assert_equal( caught, true )

  end
  
  
  #* Check that a new edge can be added to the graph with updating vertices
  def test_adding_edge
    
    # Start a new graph with no vertices
    graph = Graph.new()
       
    # Add 2 vertices to the graph
    origin = {  "code" => "NYC" ,
                "name" => "New York" ,
                "country" => "US" ,
                "continent" => "North America" ,
                "timezone" => -5 ,
                "coordinates" => { "N" => 41, "W" => 74 } ,
                "population" => 22200000 ,
                "region" => 3 }
                
    destination = { "code" => "WAS" ,
                    "name" => "Washington" ,
                    "country" => "US" ,
                    "continent" => "North America" ,
                    "timezone" => -5 ,
                    "coordinates" => {"N" => 39, "W" => 77} ,
                    "population" => 8250000 ,
                    "region" => 3 }                 
    graph.add_node(origin)
    graph.add_node(destination)
    
    assert_equal( graph.nodes().size, 2)
   
    # Add a two-way edge for the two vertices
    distance = 1370   
    graph.add_edge(origin["code"] , destination["code"], distance)
    graph.add_edge(destination["code"] , origin["code"], distance)
    
    assert_equal( graph.nodes["NYC"].neighbors.size, 1)
    assert_equal( graph.nodes["WAS"].neighbors.size, 1)
    assert_equal( graph.nodes["NYC"].neighbors["WAS"], distance)
    assert_equal( graph.nodes["WAS"].neighbors["NYC"], distance)
      
  end
  
  
  #* Check if the graph can return a list of all of its serviced cities
  def test_get_all_cities
    
    test_map = ' { "metros" : [ {
                              "code" : "LON" ,
                              "name" : "London",
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1
                            } , {
                              "code" : "PAR" ,
                              "name" : "Paris" ,
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1
                            } , {
                              "code" : "LIM" ,
                              "name" : "Lima" ,
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1 
                            } , {
                              "code" : "MOW" ,
                              "name" : "Moscow" ,
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1
                            } ] ,
                   "routes" : [ {
                              "ports" : ["LON" , "PAR"] ,
                              "distance" : 2410
                            } , {
                              "ports" : ["LON" , "MOW"] ,
                              "distance" : 4323
                            } , {
                              "ports" : ["LIM" , "PAR"] ,
                              "distance" : 4323
                            } ] } '
    graph = Graph.new()
    graph.parse_json_string(test_map)
    
    result = graph.get_all_cities()
    
    assert_equal( result.scan(/[A-Z]*, [A-Z]{3}/).size, 4)
    assert_equal( result.include?("London, LON"), true )
    assert_equal( result.include?("Moscow, MOW"), true )
    assert_equal( result.include?("Lima, LIM"), true )
    assert_equal( result.include?("Paris, PAR"), true )
    
  end
  
  
  #* Check if information on a specific city in the graph can be retrieved
  def test_specific_info
    
    # Start a new graph with no vertices
    graph = Graph.new()
       
    # Add 2 vertices to the graph
    origin = {  "code" => "NYC" ,
                "name" => "New York" ,
                "country" => "US" ,
                "continent" => "North America" ,
                "timezone" => -5 ,
                "coordinates" => { "N" => 41, "W" => 74 } ,
                "population" => 22200000 ,
                "region" => 3 }
                
    destination = { "code" => "WAS" ,
                    "name" => "Washington" ,
                    "country" => "US" ,
                    "continent" => "North America" ,
                    "timezone" => -5 ,
                    "coordinates" => {"N" => 39, "W" => 77} ,
                    "population" => 8250000 ,
                    "region" => 3 }                 
    graph.add_node(origin)
    graph.add_node(destination)
    
    assert_equal(graph.get_specific_info("CHI"), "City doesn't exist in the graph.")
    
    # Get information on Washington and check that correct information is
    # contained in the return value
    info = graph.get_specific_info("WAS")
    
    assert_equal( info.include?("WAS"), true )
    assert_equal( info.include?("Washington"), true )
    assert_equal( info.include?("US"), true )
    assert_equal( info.include?("North America"), true )
    assert_equal( info.include?("N 39, W 77"), true )
    assert_equal( info.include?("Population: 8250000"), true )
    assert_equal( info.include?("Region: 3"), true )
    assert_equal( info.include?("Direct Connections: WAS"), false )
    
    # Add an edge and check if that information is reflected in the return value
    graph.add_edge("NYC","WAS" ,570)
    info = graph.get_specific_info("NYC")
    
    assert_equal( info.include?("Direct Connections: WAS - 570"), true)

  end
  
  
  #* Check if all edges can be represented as flights in one string
  def test_formatting_all_edges
    
    test_map = ' { "metros" : [ {
                              "code" : "LON" ,
                              "name" : "London" ,
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1
                            } , {
                              "code" : "PAR" ,
                              "name" : "Paris" ,
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1
                            } , {
                              "code" : "LIM" ,
                              "name" : "Lima" ,
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1
                            } , {
                              "code" : "MOW" ,
                              "name" : "Moscow" ,
                              "country" : "X" ,
                              "continent" : "X" ,
                              "timezone" : 1 ,
                              "coordinates" : {"N" : 1, "E" : 1} ,
                              "population" : 1,
                              "region" : 1
                            } ] ,
                   "routes" : [ {
                              "ports" : ["LON" , "PAR"] ,
                              "distance" : 2410
                            } , {
                              "ports" : ["LON" , "MOW"] ,
                              "distance" : 4323
                            } , {
                              "ports" : ["LIM" , "PAR"] ,
                              "distance" : 4323
                            } ] } '
    graph = Graph.new()
    graph.parse_json_string(test_map)
   
    result = graph.format_all_edges()
    
    # All edges are parsed as 2 way, one flight is of the format XXX-XXX
    # Also account for commas inbetween and no comma at the end
    correct_length = 3 * 8 * 2 - 1
    assert_equal( result.length(), correct_length)
    
    # Check contents using a regexp
    assert_equal( result.scan(/[A-Z]{3}-[A-Z]{3},?/).size, 6)
    
    # Check if result contains some particular flights
   assert_equal( result.include?("PAR-LIM"), true)
   assert_equal( result.include?("LON-MOW"), true)
    
  end
  
  #* Check if dijkstra path search returns the shortest path among all paths
  #* NOTE: Function returns a reverse flight
  def test_shortest_path

    test_map = ' { "metros" : [ {
                                  "code" : "LON" ,
                                  "name" : "London" ,
                                  "country" : "X" ,
                                  "continent" : "X" ,
                                  "timezone" : 1 ,
                                  "coordinates" : {"N" : 1, "E" : 1} ,
                                  "population" : 1,
                                  "region" : 1
                                } , {
                                  "code" : "PAR" ,
                                  "name" : "Paris" ,
                                  "country" : "X" ,
                                  "continent" : "X" ,
                                  "timezone" : 1 ,
                                  "coordinates" : {"N" : 1, "E" : 1} ,
                                  "population" : 1,
                                  "region" : 1
                                } , {
                                  "code" : "LIM" ,
                                  "name" : "Lima" ,
                                  "country" : "X" ,
                                  "continent" : "X" ,
                                  "timezone" : 1 ,
                                  "coordinates" : {"N" : 1, "E" : 1} ,
                                  "population" : 1,
                                  "region" : 1
                                } , {
                                  "code" : "MOW" ,
                                  "name" : "Moscow" ,
                                  "country" : "X" ,
                                  "continent" : "X" ,
                                  "timezone" : 1 ,
                                  "coordinates" : {"N" : 1, "E" : 1} ,
                                  "population" : 1,
                                  "region" : 1
                                } ] ,
                       "routes" : [ {
                                  "ports" : ["LON" , "PAR"] ,
                                  "distance" : 200
                                } , {
                                  "ports" : ["PAR" , "LIM"] ,
                                  "distance" : 400
                                } , {
                                  "ports" : ["LIM" , "MOW"] ,
                                  "distance" : 600
                                } , {
                                  "ports" : ["PAR" , "MOW"] ,
                                  "distance" : 600
                                }] } '  
    graph = Graph.new()
    graph.parse_json_string(test_map)

    # There is a less direct path (more stop overs) with shortest distance
    assert_equal( graph.get_dijkstra_path("LON","MOW"), "LON-PAR-MOW" )
    
    test_map = ' { "metros" : [ {
                                      "code" : "LON" ,
                                      "name" : "London" ,
                                      "country" : "X" ,
                                      "continent" : "X" ,
                                      "timezone" : 1 ,
                                      "coordinates" : {"N" : 1, "E" : 1} ,
                                      "population" : 1,
                                      "region" : 1
                                    } , {
                                      "code" : "PAR" ,
                                      "name" : "Paris" ,
                                      "country" : "X" ,
                                      "continent" : "X" ,
                                      "timezone" : 1 ,
                                      "coordinates" : {"N" : 1, "E" : 1} ,
                                      "population" : 1,
                                      "region" : 1
                                    } , {
                                      "code" : "LIM" ,
                                      "name" : "Lima"  ,
                                      "country" : "X" ,
                                      "continent" : "X" ,
                                      "timezone" : 1 ,
                                      "coordinates" : {"N" : 1, "E" : 1} ,
                                      "population" : 1,
                                      "region" : 1
                                    } , {
                                      "code" : "MOW" ,
                                      "name" : "Moscow" ,
                                      "country" : "X" ,
                                      "continent" : "X" ,
                                      "timezone" : 1 ,
                                      "coordinates" : {"N" : 1, "E" : 1} ,
                                      "population" : 1,
                                      "region" : 1
                                    } ] ,
                           "routes" : [ {
                                      "ports" : ["LON" , "PAR"] ,
                                      "distance" : 200
                                    } , {
                                      "ports" : ["PAR" , "LIM"] ,
                                      "distance" : 200
                                    } , {
                                      "ports" : ["LIM" , "MOW"] ,
                                      "distance" : 200
                                    } , {
                                      "ports" : ["PAR" , "MOW"] ,
                                      "distance" : 500
                                    }] } '  
    graph = Graph.new()
    graph.parse_json_string(test_map)
    
    # The flight with more stop overs is shorter
    assert_equal( graph.get_dijkstra_path("LON","MOW"), "LON-PAR-LIM-MOW" )
        
  end
  
  
  #* Check if sending get requests to gcmap website doesn't cause any errors
  def test_gcmapping
    graph = Graph.new()
    graph.parse_json_file("CSAirData.json")
    
    # Test some non CS Air flights
    assert_equal( graph.map("NYC-CHI"), true)
    assert_equal( graph.map("BOG-MEX-MOW"), true)
    
    # Test for CS Air flights only
    assert_equal( graph.map( graph.get_dijkstra_path("MEX","SYD") ), true )
    assert_equal( graph.map( graph.get_dijkstra_path("MOW","LIM") ), true )
  end
  
  
end