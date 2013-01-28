require "graph.rb"
require "test/unit"

=begin

  Unit test for calculating statistics of a flight network.
  Simulates a route map and compares results with expected values.

  @author Timur Reziapov <reziapo1@illinois.edu>
  @date Sunday, September 31, 2012 15:00 PM

=end

class StatsTest < Test::Unit::TestCase
  
  #* Check calculation of graph on a made up graph where
  #* we can easily calculate statistics
  def test_general_statistics
  
    test_map = ' { "metros" : [ {
                                  "code" : "A" ,
                                  "name" : "Milan" ,
                                  "continent" : "Europe" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 100 
                                } , {
                                  "code" : "B" ,
                                  "name" : "Essen" ,
                                  "continent" : "Africa" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 200
                                } , {
                                  "code" : "C" ,
                                  "name" : "St. Petersburg" ,
                                  "continent" : "Europe" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 500 
                                } , {
                                  "code" : "D" ,
                                  "name" : "Moscow" ,
                                  "continent" : "Europe" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 400
                                } , {
                                  "code" : "E" ,
                                  "name" : "Ez" ,
                                  "continent" : "South America" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 300
                                } ] , 
                   "routes" : [
                                {
                                  "ports" : ["A" , "B"] ,
                                  "distance" : 100
                                } , {
                                  "ports" : ["C" , "D"] ,
                                  "distance" : 200
                                } , {
                                  "ports" : ["E" , "B"] ,
                                  "distance" : 300
                                } , {
                                  "ports" : ["A" , "D"] ,
                                  "distance" : 400
                                } ] }'
    graph = Graph.new()
    graph.parse_json_string(test_map)
    
    distance, origin, destination = graph.get_shortest_flight

    assert_equal( distance, 100 )
    assert_equal( origin == "A" || destination == "A", true )
    assert_equal( origin == "B" || destination == "B", true )

    distance, origin, destination = graph.get_longest_flight

    assert_equal( distance, 400)
    assert_equal( origin == "A" || destination == "A", true )
    assert_equal( origin == "D" || destination == "D", true )
    
    assert_equal( graph.get_average_distance, (100 + 200 + 300 + 400) / 4)
    
    population, code = graph.get_smallest_city()

    assert_equal( population, 100)
    assert_equal( code, "A")
    
    population, code = graph.get_biggest_city()

    assert_equal( population, 500)
    assert_equal( code, "C")
    
    assert_equal( graph.get_average_population, (100 + 200+ 300 + 400 + 500) / 5)
    
    continents_hash = graph.get_continents_with_cities

    assert_equal( continents_hash.keys.size, 3 )
    assert_equal( continents_hash.key?("Europe"), true )
    assert_equal( continents_hash.key?("Africa"), true )
    assert_equal( continents_hash.key?("South America"), true )

    hubs_array, degree = graph.get_hub_cities

    assert_equal( degree, 2)
    assert_equal( hubs_array.size, 3 )
    assert_equal( hubs_array.include?("A"), true )
    assert_equal( hubs_array.include?("B"), true )
    assert_equal( hubs_array.include?("D"), true )
      
  end


  #* Tests the functionality of calculating flight time
  def test_time_calculation()

    graph = Graph.new()
    graph.parse_json_file("CSAirData.json")

    # Test illegal arguments
    assert_raise( RuntimeError ) { graph.calculate_time(0) }
    assert_raise( RuntimeError ) { graph.calculate_time(-12123) }
    assert_raise( RuntimeError ) { graph.calculate_time("") }
    assert_raise( RuntimeError ) { graph.calculate_time("asdads") }

    test_distance = 400
    flight_time = 0

    assert_nothing_raised( RuntimeError ) { flight_time = graph.calculate_time(test_distance) }

    # Pre-calculate answer using another formula: vi^2 = v^2 + 2ad, v = vi + at
    vi = 0.0
    v = 750.0
    a = ( (v ** 2) - (vi ** 2) ) / ( 2 * test_distance / 2)
    t = (v - vi) / a

    assert_equal( flight_time, Integer( 2 * t * 60 ) )

    # Test a distance of less than 400
    test_distance = 257
    t = (v - vi) / ( ( (v ** 2) - (vi ** 2) ) / ( 2 * test_distance / 2) )

    assert_nothing_raised( RuntimeError ) { flight_time = graph.calculate_time(test_distance) }
    assert_equal( flight_time, Integer( 2 * t * 60 ) )

    # Test a distance of greather than 400, must account for cruising time
    test_distance = 5379

    # Calculate time for take off and landing
    t = (v - vi) / ( ( (v ** 2) - (vi ** 2) ) / ( 2 * 400 / 2) )

    # Calculate time cruising
    tc = ( test_distance - 400 ) / 750.0

    assert_nothing_raised( RuntimeError ) { flight_time = graph.calculate_time(test_distance) }
    assert_equal( flight_time, Integer( 2 * t * 60 + tc * 60 ) )

  end


  #* Checks the calcuation of time spend on a layover in some city in the network
  def test_layover_time_calculation

    graph = Graph.new()
    graph.parse_json_file("CSAirData.json")

    # Test some existing city
    test_city_code = "TYO"
    num_connections = graph.nodes[test_city_code].neighbors.size()

    base_layover_minutes = 120

    assert_equal( graph.calculate_layover_time(test_city_code), 
                  base_layover_minutes - (num_connections - 1) * 10 )

    # Add a new unreachable city, check if layover time equals base time
    new_vertex = {  "code" => "ABC" ,
                    "name" => "AaBbCc" ,
                    "country" => "ABC" ,
                    "continent" => "North America" ,
                    "timezone" => -5 ,
                    "coordinates" => { "N" => 41, "W" => 74 } ,
                    "population" => 22200000 ,
                    "region" => 3 }

    graph.add_node(new_vertex)

    assert_equal( graph.calculate_layover_time("ABC"), 
                  base_layover_minutes )

  end


  #* Checks the calculation of statistics on a route in the network
  def test_route_statistics()

    test_map = ' { "metros" : [ {
                                  "code" : "A" ,
                                  "name" : "Milan" ,
                                  "continent" : "Europe" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 100 
                                } , {
                                  "code" : "B" ,
                                  "name" : "Essen" ,
                                  "continent" : "Africa" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 200
                                } , {
                                  "code" : "C" ,
                                  "name" : "St. Petersburg" ,
                                  "continent" : "Europe" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 500 
                                } , {
                                  "code" : "D" ,
                                  "name" : "Moscow" ,
                                  "continent" : "Europe" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 400
                                } , {
                                  "code" : "E" ,
                                  "name" : "Ez" ,
                                  "continent" : "South America" ,
                                  "country" : "CH" ,
                                  "timezone" : 8 ,
                                  "coordinates" : {"N" : 40, "E" : 117} ,
                                  "region" : 4 ,
                                  "population" : 300
                                } ] , 
                   "routes" : [
                                {
                                  "ports" : ["A" , "B"] ,
                                  "distance" : 100
                                } , {
                                  "ports" : ["C" , "D"] ,
                                  "distance" : 200
                                } , {
                                  "ports" : ["E" , "B"] ,
                                  "distance" : 300
                                } , {
                                  "ports" : ["A" , "D"] ,
                                  "distance" : 400
                                } ] }'

    graph = Graph.new()
    graph.parse_json_string(test_map)

    distance, cost, time = 0, 0, 0

    # Test calling on invalid routes
    assert_raise( RuntimeError ) { distance, cost, time = graph.get_route_info() }
    assert_raise( RuntimeError ) { distance, cost, time = graph.get_route_info("A") }
    assert_raise( RuntimeError ) { distance, cost, time = graph.get_route_info("") }
    assert_raise( RuntimeError ) { distance, cost, time = graph.get_route_info("A", "A") }

    # This flight is non direct, error should be thrown
    assert_raise( RuntimeError ) { distance, cost, time = graph.get_route_info("B", "D") }

    # Test valid non-stop route
    assert_nothing_raised( RuntimeError ) { distance, cost, time = graph.get_route_info("A", "B") }
    assert_equal( distance, 100 )
    assert_equal( cost, 100 * 0.35 )
    assert_equal( time, graph.calculate_time(distance) )

    # Test valid multiple-stops routes
    assert_nothing_raised( RuntimeError ) { distance, cost, time = graph.get_route_info("B", "A", "D") }
    assert_equal( distance, 100 + 400 )
    assert_equal( cost, 100 * 0.35 + 400 * 0.30)
    assert_equal( time, graph.calculate_time(100) + 
                        graph.calculate_time(400) + 
                        graph.calculate_layover_time("A") )

    assert_nothing_raised( RuntimeError ) { distance, cost, time = graph.get_route_info("A", "D", "A", "B") }
    assert_equal( distance, 400 * 2 + 100 )
    assert_equal( cost, 400 * 0.35 + 400 * 0.30 + 100 * 0.25)
    assert_equal( time, graph.calculate_time(400) * 2 + 
                        graph.calculate_time(100) + 
                        graph.calculate_layover_time("D") + 
                        graph.calculate_layover_time("A") )

    # Check that the cost doesn't change if there's been more than 7 stops
    d, c, t = graph.get_route_info("A", "D", "A", "B", "A", "D", "A", "B", "A")
    d2, c2, t2 = graph.get_route_info("A", "D", "A", "B", "A", "D", "A", "B", "A", "D", "A")

    assert_equal( d < d2, true )
    assert_equal( t < t2, true )
    assert_equal( c == c2, true )

  end
  
end
