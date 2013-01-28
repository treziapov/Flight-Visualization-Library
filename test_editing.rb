require 'test/unit'
require 'graph.rb'

=begin

  Unit tests for graph editing features.

  @author Timur Reziapov <reziapo1@illinois.edu>
  @date Sunday, October 7th, 2012 17:00 PM

=end

class GraphTest < Test::Unit::TestCase

	#* This code initializes the test graph before each test runs.
	def setup

		@graph = Graph.new()
		@graph.parse_json_file("CSAirData.json")

	end


	#* Check the functionality of exists? method.
	def test_exists()

		assert_equal( @graph.exists?("SHA"), true )
		assert_equal( @graph.exists?("LIM"), true )

		assert_equal( @graph.exists?(""), false )
		assert_equal( @graph.exists?("LONDON"), false )
		assert_equal( @graph.exists?("DXB"), false )

	end


	#* Checks the functionality of adjacent? method.
	def test_adjacent()

		# Choose a specific city and check if functions returns true on its neighbors
		test_city_code = "SHA"
		@graph.nodes[test_city_code].neighbors.each_key do |neighbor_code|
			assert_equal( @graph.adjacent?(test_city_code, neighbor_code), true )
			assert_equal( @graph.adjacent?(neighbor_code, test_city_code), true )
		end

		# Test some non-neighbor cities
		assert_equal( @graph.adjacent?(test_city_code, "NYC"), false )
		assert_equal( @graph.adjacent?("NYC", test_city_code), false )
		assert_equal( @graph.adjacent?(test_city_code, "PAS"), false )
		assert_equal( @graph.adjacent?("PAS", test_city_code), false )

		# Test some non-existent cities
		assert_equal( @graph.adjacent?(test_city_code, "A"), false )
		assert_equal( @graph.adjacent?("A", test_city_code), false )
		assert_equal( @graph.adjacent?(test_city_code, "Chicago"), false )
		assert_equal( @graph.adjacent?("Chicago", test_city_code), false )

	end


	#* Tests removing a direct flight from the nework.
	#* NOTE: Expected functionality is removing flight in one direction only
	def test_remove_flight()

		# Choose a specific flight and remove flight in one direction
		origin_code = "ATL"
		destination_code = "MIA"

		assert_equal( @graph.remove_edge(origin_code, destination_code), true )
		assert_equal( @graph.adjacent?(origin_code, destination_code), false )
		assert_equal( @graph.adjacent?(destination_code, origin_code), true )

		# Remove the flight in the other direction and checks if graph is updated
		assert_equal( @graph.remove_edge(destination_code, origin_code), true )
		assert_equal( @graph.adjacent?(origin_code, destination_code), false )
		assert_equal( @graph.adjacent?(destination_code, origin_code), false )

		# Try removing non-direct flights
		assert_equal( @graph.remove_edge(origin_code, "MIA"), false )
		assert_equal( @graph.remove_edge("MIA", origin_code), false )
		assert_equal( @graph.remove_edge(origin_code, "NYC"), false )
		assert_equal( @graph.remove_edge("NYC", origin_code), false )


		# Try removing non-existent flights
		assert_equal( @graph.remove_edge(origin_code, "DXB"), false )
		assert_equal( @graph.remove_edge("DXB", origin_code), false )
		assert_equal( @graph.remove_edge("ABC", ""), false )
		assert_equal( @graph.remove_edge(origin_code, origin_code), false )

	end


	#* Tests removing a city from the nework. 
	#* Required removing all flights associated with the city from the network as well.
	def test_remove_city()

		# Choose some test city, save its neighbors and remove it from the network
		test_city_code = "SHA"
		previous_neighbors = @graph.nodes[test_city_code].neighbors.keys

		assert_equal( @graph.remove_node(test_city_code), true )

		# Check if the city no longer exists in the network and previous neighbors can't reach it
		assert_equal( @graph.exists?(test_city_code), false )
		assert_equal( @graph.get_specific_info(test_city_code), "City doesn't exist in the graph.")

		previous_neighbors.each do |neighbor_code|
			assert_equal( @graph.adjacent?(neighbor_code, test_city_code), false )
		end

		# Test removing non-existent city
		assert_equal( @graph.remove_node(test_city_code), false )
		assert_equal( @graph.remove_node(""), false )
		assert_equal( @graph.remove_node("DXB"), false )

	end


	#* Tests editing of an existing city.
	def test_editing_city()

		# Make a modified nformation hash for an existing city in the network without changing the key
		old_code = "NYC"
		updated_vertex_old_code = {  
									"code" => old_code ,
				                    "name" => "New York City" ,
				                    "country" => "USA" ,
				                    "continent" => "North America " ,
				                    "timezone" => -10 ,
				                    "coordinates" => { "N" => 10, "W" => 0 } ,
				                    "population" => 100 ,
				                    "region" => 3 }

		# Check that new values are indeed different from current ones
		assert_equal( @graph.nodes[old_code].name.eql?(updated_vertex_old_code["name"]), false )
		assert_equal( @graph.nodes[old_code].country.eql?(updated_vertex_old_code["country"]), false )
		assert_equal( @graph.nodes[old_code].population.eql?(updated_vertex_old_code["population"]), false )

		# Edit the city information and check that the node is updated
		@graph.edit_node( updated_vertex_old_code["code"], updated_vertex_old_code )

		assert_equal( @graph.nodes[old_code].name.eql?(updated_vertex_old_code["name"]), true )
		assert_equal( @graph.nodes[old_code].country.eql?(updated_vertex_old_code["country"]), true )
		assert_equal( @graph.nodes[old_code].population.eql?(updated_vertex_old_code["population"]), true )


		# Make a short modified information hash for an existing city in the network and change its key
		new_code = "TEST"
		updated_vertex_new_code = {  
									"code" => new_code ,
				                    "name" => "New York" ,
				                    "population" => 5000 }

		# Edit the city information and check that the old code no longer corresponds to a node
		# and the updated node is avilable through the updated code
		@graph.edit_node( old_code, updated_vertex_new_code )

		assert_equal( @graph.exists?(old_code), false )
		assert_equal( @graph.exists?(new_code), true )
		assert_equal( @graph.nodes[new_code].population.eql?(updated_vertex_new_code["population"]), true )
		assert_equal( @graph.nodes[new_code].population.eql?(updated_vertex_old_code["population"]), false )
		assert_equal( @graph.nodes[new_code].name.eql?(updated_vertex_new_code["name"]), true)
		assert_equal( @graph.nodes[new_code].name.eql?(updated_vertex_old_code["name"]), false)

		# Check that old information is retained
		assert_equal( @graph.nodes[new_code].country.eql?(updated_vertex_old_code["country"]), true )
		assert_equal( @graph.nodes[new_code].region.eql?(updated_vertex_old_code["region"]), true )

		# Test editing non-existent city
		caught = false
		begin
			assert_equal( @graph.exists?("non-existent"), true )
			@graph.edit_node("non_existent", updated_vertex_old_code)
		rescue
			caught = true
		end
		assert_equal( caught, true )

		# Test non-changing calls
		@graph.edit_node( new_code, Hash.new() )

		assert_equal( @graph.nodes[new_code].population.eql?(updated_vertex_new_code["population"]), true )
		assert_equal( @graph.nodes[new_code].name.eql?(updated_vertex_new_code["name"]), true)

		@graph.edit_node( new_code, nil )

		assert_equal( @graph.nodes[new_code].population.eql?(updated_vertex_new_code["population"]), true )
		assert_equal( @graph.nodes[new_code].name.eql?(updated_vertex_new_code["name"]), true)

	end


	#* Tests graph to json conversion by checking if the generated json
	#* produces a graph with the same network information
	def test_to_json()

		# Make a new graph from json representation of test @graph
		test_graph = Graph.new()
		test_graph.parse_json_string( @graph.to_json )

		# Check if both graphs have the same number of cities in the network
		assert_equal( @graph.nodes.keys.size, test_graph.nodes.size )

		# Loop through all nodes and edges of @graph and check if they exist in test_graph
		@graph.nodes.each do |code, node|

			# Check if each pair of nodes has the same contents
			assert_equal( node.eql?( test_graph.nodes[code] ), true )

		end

		# Loop through all nodes and edges of test_graph and check if they exist in @graph
		test_graph.nodes.each do |code, node|

			# Check if each pair of nodes has the same contents
			assert_equal( node.eql?( @graph.nodes[code] ), true )

		end

	end


	#* Test expanding network by parsing additional .json files
	def test_expanding()

		# Save some statistics to compare as some should change with expansion
		original_average_flight = @graph.get_average_distance
		original_shortest_flight = @graph.get_shortest_flight
		original_longest_flight = @graph.get_longest_flight
		original_biggest_city = @graph.get_biggest_city
		original_average_population = @graph.get_average_population
		original_hubs, original_degree = @graph.get_hub_cities
		original_num_continents = @graph.get_continents_with_cities.keys.size

		assert_equal( @graph.parse_json_file("ExtraData.json"), true )
		assert_equal( @graph.exists?("CMI"), true )

		# Check the statistics that must have changed
		assert_not_equal( original_average_flight, @graph.get_average_distance )
		assert_not_equal( original_shortest_flight, @graph.get_shortest_flight )
		assert_not_equal( original_average_population, @graph.get_average_population )

		new_hubs, new_degree = @graph.get_hub_cities

		assert_not_equal( original_hubs, new_hubs )
		assert_not_equal( original_degree, new_degree )

		# Check the statistics that shouldn't have changed
		assert_equal( original_biggest_city, @graph.get_biggest_city )
		assert_equal( original_longest_flight, @graph.get_longest_flight )
		assert_equal( original_num_continents, @graph.get_continents_with_cities.keys.size )

	end

end
