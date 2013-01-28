require 'rubygems'
require 'json'
require 'open-uri'
require 'priority_queue'
require 'node.rb'
require 'set'
require 'orderedhash'
require 'active_support'


INFINITY = 1 << 64
CRUISING_SPEED = 750.0
BASE_LAYOVER_TIME_MINS = 120

=begin

  This class will hold the data for CSAir Flights.

  @author Timur Reziapov <reziapo1@illinois.edu>
  @date Sunday, September 31, 2012 15:00 PM

=end

class Graph
  
  # Make the class nodes field public
  attr_reader :nodes
  
  
  #* Constructor.
  def initialize(nodes = nil)
    @nodes = Hash.new()
    @sources = Hash[ "data sources" => Array.new() ]
  end
  
  
  #* Parses a JSON file into a graph structure.
  #* @param filename - the name of the JSON file to parse
  #* @return true if file was parsed successfully 
  #*         false otherwise
  def parse_json_file(filename)
    
    begin
      file = File.open(filename)
    rescue
      puts "Couldn't open the file."
      return false
    end
    
    # Get the contents of the given JSON file
    text = String.new()
    file.each {|line| text += line } 
    file.close
    
    return parse_json_string(text)
    
  end
  
  
  #* Parses a JSON string into a graph structure.
  #* @param text - text in JSON format to parse to the graph
  #* @return true if text was parsed successfully
  #*         false otherwise
  def parse_json_string(text)
   
    # Parse JSON string to a hash table
    begin
      json_hash = JSON.parse(text)
    rescue
      puts "Couldn't parse the JSON file contents."
      return false
    end
      
    # Store the sources information if its available
    if ( json_hash.has_key?("data sources") )
      json_hash["data sources"].each do |source|
        if !@sources["data sources"].include?(source)
          @sources["data sources"].push(source)
        end
      end
    end

    # Exit if there is no data to make vertices from
    if ( !json_hash.has_key?("metros") || !json_hash.has_key?("routes") )
      puts "No \"metros\" and or \"routes\" key in the JSON file."
      return false
    end
    
    # Assume JSON file is in the right format if the keys do exist
    # Setup the vertices/cities
    json_hash["metros"].each do |metro_hash| 
      add_node(metro_hash)
    end
    
    # Setup the edges/flights
    json_hash["routes"].each do |route_hash|
      
      # Add edges for both cities
      cities = route_hash["ports"]
      distance = route_hash["distance"]

      raise "Missing keys for a new edge." if ( cities.nil? || distance.nil? )
      add_edge(cities[0], cities[1], distance)
      add_edge(cities[1], cities[0], distance)
      
    end
    
    return true
    
  end
  
  
  #* Adds a new vertex to the Graph structure.
  #* @param code - the new key to add to the @nodes hash table
  #* @param hash - the value corresponding to the new key
  def add_node(hash)

    raise "Nil Hash for new node." if hash.nil?

    raise "Invalid format of hash for new node." if !valid_node_format(hash)

    raise "City already exists!" if exists?( hash["code"] )

    @nodes[ hash["code"] ] = Node.new(hash)

  end
  
  
  #* Adds an edge from origin Node to destination Node with the given distance.
  #* @param origin - the starting city/vertex
  #* @param destination - the target city/vertex
  #* @param distance - the distance between the two cities/vertices
  def add_edge(origin_code, destination_code, distance)
    
    # If origin vertex doesn't exist, do nothing
    if ( !exists?(origin_code) || !exists?(destination_code) )
      raise "Code doesn't exist in graph."
    end

    if ( !distance.is_a?(Integer) || distance < 0)
      raise "Invalid distance!"
    end
    
    @nodes[origin_code].neighbors[destination_code] = distance 
  end


  #* Changes the members of a node acording to information in new hash.
  #* If code is changed, removes the old node and make a new one.
  #* NOTE: Changing connections is impossible by this function.
  def edit_node(original_code, new_hash)

    raise "Non-existent code." if !exists?(original_code)

    return if new_hash.nil? || new_hash.empty?

    # Get the original node information and update it according to the new hash
    original_node = @nodes[original_code]
    original_node.update(new_hash)

    # If code was changed, remove the old node and put it back with the new key
    if new_hash.key?("code") && !original_code.eql?( new_hash["code"] )
      @nodes[ new_hash["code"] ] = original_node
      remove_node(original_code)
    end

  end

  #* Returns a list of all cities with codes.
  def get_all_cities()
    
    result = String.new()
    @nodes.each_pair do |code, node|
      result += node.name + ", " + node.code + "\n"
    end
    
    return result
    
  end
  
  
  #* Prints detailed information on a given city/node.
  #* @param city - the vertex to query information for, has to be a city code.
  #* @return detailed information on a city that exists in the graph as a string
  #*         error message otherwise
  def get_specific_info(city_code)
    
    city = @nodes[city_code]
    
    if city.nil?
      return "City doesn't exist in the graph."
    end
      
    result = String.new("Code: ") + city.code + "\n"
    result += "Name: " + city.name + "\n"
    result += "Country: " + city.country + "\n"
    result += "Continent: " + city.continent + "\n"
    result += "Time Zone: " + "#{city.timezone}" + "\n"
    result += "Coordinates: " + get_coords(city.code) + "\n"
    result += "Population: #{city.population}" + "\n"
    result += "Region: #{city.region}" + "\n"
    result += "Direct Connections: "
   
    # Format all reachable neighbor cities
    counter = 0
    num_neighbors = city.neighbors.size
    city.neighbors.each_pair do |neighbor, distance|
      counter = counter + 1
      result += neighbor + " - #{distance}" + ( (counter < num_neighbors) ? ", " : "." ) 
    end
    
    return result
    
  end
  
  
  #* Returns the distance of the shortest flight in the network
  #* and the city codes associated with the flight
  def get_shortest_flight()

    shortest = INFINITY
    origin = nil
    destination = nil

    @nodes.each_value do |node|
      node.neighbors.each do |code, distance|
        if distance < shortest
          shortest = distance
          origin = node.code
          destination = code
        end
      end
    end

    return shortest, origin, destination

  end


  #* Returns the distance of the longest flight in the network
  #* and the city codes associated with the flight
  def get_longest_flight()

    longest = -1
    origin = nil
    destination = nil

    @nodes.each_value do |node|
      node.neighbors.each do |code, distance|
        if distance > longest
          longest = distance
          origin = node.code
          destination = code
        end
      end
    end

    return longest, origin, destination

  end


  #* Returns the average distance of all flights in the network
  def get_average_distance()

    total = 0
    num_flights = 0

    @nodes.each_value do |node|
      node.neighbors.each do |code, distance|
        total += distance
        num_flights += 1
      end
    end

    return 0 if num_flights == 0
    return total / num_flights

  end


  #* Returns the code of the biggest city and its population
  def get_biggest_city()

    biggest = -1
    code = nil

    @nodes.each_value do |node|
      if biggest < node.population
        biggest = node.population
        code = node.code
      end
    end

    return biggest, code

  end


  #* Returns the code of the smallest city and its population
  def get_smallest_city()

    smallest = INFINITY
    code = nil

    @nodes.each_value do |node|
      if smallest > node.population
        smallest = node.population
        code = node.code
      end
    end

    return smallest, code

  end


  #* Returns the average population of the cities in the network
  def get_average_population()

    total = 0
    num_cities = 0

    @nodes.each_value do |node|
      total += node.population
      num_cities += 1
    end

    return 0 if num_cities == 0
    return total / num_cities

  end


  #* Returns the list of continents served and cities in each continent
  def get_continents_with_cities()

    result = Hash.new()

    @nodes.each_value do |node|

      if !result.key?(node.continent)
        result[node.continent] = Set.new()
      end
      result[node.continent].add?(node.code)

    end

    return result

  end


  #* Returns the codes of cities with most connections and the number of 
  #* these connections
  def  get_hub_cities()

    max_degree = 0
    hubs = Array.new()

    @nodes.each_value do |node|
      degree = node.neighbors.size
      if degree > max_degree
        max_degree = degree
        hubs = Array.new(1, node.code)
      elsif degree == max_degree
          hubs.push(node.code)
      end
    end

    return hubs, max_degree

  end

  #* Helper Function. Returns a string with node's coordinates
  #* @param node - the Node which coordinates to return
  #* @return coordinates of the node in string format
  def get_coords(cidy_code)
    node = @nodes[cidy_code]
    coords_string = String.new()
    coords_hash = node.coordinates
    
    if (coords_hash.has_key?("S"))
      coords_string += "S #{coords_hash["S"]}, "
    else
      coords_string += "N #{coords_hash["N"]}, "
    end

    if (coords_hash.has_key?("W"))
      coords_string += "W #{coords_hash["W"]}"
    else
      coords_string += "E #{coords_hash["E"]}"
    end
    
    return coords_string
    
  end
  
  #* Returns all possible flights as one formatted string for gcmap
  def format_all_edges()
    
    result = String.new()
    nodes.each_pair do |code, node|
      
      node.neighbors.each_pair do |city_code, distance|
        result += code + "-" + city_code +","
      end  
      
    end
    
    return result.chop
    
  end


  #* Returns the shortest path from origin city to destination city
  #* @param origin_code the code of city to start looking from
  #* @param destination_code the code of the city to find path to
  #* @return string of codes if successful
  #*         nil otherwise
  def get_dijkstra_path(origin_code, destination_code)
    
    # Check for illegal argument codes
    return nil if ( !exists?(origin_code) || 
                    !exists?(destination_code) )
    
    # Initialize data structures to perform BFS traversal
    pqueue = PriorityQueue.new()
    distance_hash = Hash.new()
    parent = Hash.new()
    
    # Insert all edges into the Priority Queue
    @nodes.each_value do |node|      
     
      pqueue.push(node, INFINITY) 
      distance_hash[node] = INFINITY
      parent[node] = nil
      
    end
    
    # Update the origin node as the start node
    origin_node = @nodes[origin_code]
    destination_node = @nodes[destination_code]
    distance_hash[origin_node] = 0
    pqueue.change_priority(origin_node, 0)
    
    # Go through the queue until target is found or error occurs
    until pqueue.empty? 
      
      current_node = pqueue.delete_min_return_key
      
      break if ( current_node.equal?(destination_node) )
            
      return nil if (distance_hash[current_node] == INFINITY)
                  
      current_node.neighbors.each do |neighbor_code, distance|
        
        alternative = distance + distance_hash[current_node]
        neighbor_node = @nodes[neighbor_code]
     
        # Update distance if alternative one is shorter
        if ( alternative < distance_hash[neighbor_node] ) 
              
          distance_hash[neighbor_node] = alternative
          parent[neighbor_node] = current_node
          pqueue.change_priority(neighbor_node, alternative)
          
        end
        
      end
      
    end
    
    current_node = destination_node 
    result = destination_code
    
    # Get the reverse flight string  
    until parent[current_node].nil?
      parent_node = parent[current_node]
      result = parent_node.code + "-" + result
      current_node = parent_node
    end
     
    return result
   
  end
   

  #* Uses the gcmap website to produce a map of given flights
  #* @param routes the string that contains cities to map
  #* return true if successful
  #*        false otherwise
  def map(routes)

    begin
      File.open("map.gif", "wb") do |fo|
        fo.write open("http://www.gcmap.com/map?P=#{routes}&MS=bm&MR=120&MX=720x360&PM=*").read
      end
    rescue
      puts "File IO Error"
      return false
    end
    
    return true
 
  end


  #* If the given code exists in the network, removes the node
  #* and all edges associated with it.
  #* @return true if code was removed
  #*         false otherwise
  def remove_node(code)

    return false if !exists?(code)

    # Remove the edges from neighbors first
    @nodes[code].neighbors.each_key do |neighbor_code|
      @nodes[neighbor_code].neighbors.delete(code)
    end

    @nodes.delete(code)
    return true

  end


  #* If an edge exists with given codes, remove it from the network.
  #* INSTRUCTOR NOTE: only remove one edge for the flight, not both
  #* @return true if edge was removed
  #*         false otherwise
  def remove_edge(origin_code, destination_code)

    return false if ( !exists?(origin_code) || !exists?(destination_code) )

    return false if ( !adjacent?(origin_code, destination_code))

    @nodes[origin_code].neighbors.delete(destination_code)
    return true

  end


  #* Returns if given code exists in the network.
  def exists?(code)
    return @nodes.include?(code)
  end


  #* Returns if there is an edge between the nodes that correspond to given keys.
  def adjacent?(origin_code, destination_code)
    return false if ( !exists?(origin_code) || !exists?(destination_code) )
    return @nodes[origin_code].neighbors.key?(destination_code)
  end
  

  #* Returns true if the given hash contains all the neccesary keys for a node,
  #* false otherwise.
  def valid_node_format(hash)
    return hash.key?("name") && hash.key?("code") && 
            hash.key?("country") && hash.key?("continent") &&
            hash.key?("timezone") && hash.key?("coordinates") &&
            hash.key?("population") && hash.key?("region")
  end


  #* Returns the data of the graph in the JSON format,
  #* by first building a hash in the same format as a valid parsed file.
  def to_json()

    # Make a new hash and copy data on sources
    formatted_hash = Hash[@sources]

    # Create an array for the metros and routes in the hash
    formatted_hash["metros"] = Array.new()
    formatted_hash["routes"] = Array.new()

    # Make a hash entry for each node in the metros array
    @nodes.each_value do |node|

      metro_hash = Hash.new()
      metro_hash["code"] = node.code
      metro_hash["name"] = node.name
      metro_hash["country"] = node.country
      metro_hash["continent"] = node.continent
      metro_hash["timezone"] = node.timezone
      metro_hash["coordinates"] = node.coordinates
      metro_hash["population"] = node.population
      metro_hash["region"] = node.region

      formatted_hash["metros"].push(metro_hash)

      # Go through all direct connections and add all routes
      # NOTE: Instructor says to treat edges as directed
      node.neighbors.each do |neighbor_code, distance|

        route_hash = Hash.new()
        route_hash["ports"] = [node.code, neighbor_code]
        route_hash["distance"] = distance
        formatted_hash["routes"].push(route_hash)

      end

    end

    return JSON.pretty_generate(formatted_hash)

  end


  #* This function returns statistics on a valid flight.
  #* @param list of citiy codes that represent desired flight
  #* @return total distance of the flight, cost of the flight, time the flight takes
  def get_route_info(*city_codes)

    # Check if argument is in valid format, raise exception if not
    raise "Missing arguments." if ( city_codes.nil? || city_codes.size < 2 )

    # Check if each code exists in the network, raise exception if not
    city_codes.each { |code| raise "Non-existent code." if !@nodes.key?(code) }

    # Calculate statistics, raise exception if the flight isn't allowed
    to_calculate = Array.new(city_codes).reverse
    current_code = to_calculate.pop
    next_code = to_calculate.pop

    total_distance = 0
    total_cost = 0.0
    total_minutes = 0

    leg_cost = 0.35

    until next_code.nil?

      # First check if current to next is a valid flight, raise exception if not
      raise "Invalid connections." if !adjacent?(current_code, next_code)

      current_distance = @nodes[current_code].neighbors[next_code]

      # Update total stats according the the current flight's distance
      total_distance += current_distance
      total_cost += current_distance * leg_cost
      total_minutes += calculate_time(current_distance)

      # Get the next direct flight's city codes
      # If to_calculate is empty, next_code will be nil and loop will end
      current_code = next_code
      next_code = to_calculate.pop

      # Update the leg cost according to how many stops there have been
      # Can't be less than 0
      leg_cost = [ leg_cost - 0.05, 0.0 ].max

      # If the flight isn't the last connection, add layover time to total flight time
      if !next_code.nil? 
        total_minutes += calculate_layover_time(current_code)
      end

    end

    return total_distance, total_cost, total_minutes

  end


  #* Returns the time it would take to travel the given disntace on a direct flight.
  def calculate_time(distance)

    raise "Non-integer distance!" if !distance.is_a?(Integer)

    raise "Nil or less than zero distance." if distance.nil? || distance <= 0

    time = 0.00

    cruising_distance = distance - 400.0
    accelerating_distance = [distance / 2.0, 200.0].min

    # Calculate lift off and landing time, both take the same time
    # Formula: t = 2d / (v + u)
    time += 2.0 * ( 2.0 * accelerating_distance / (0.0 + CRUISING_SPEED) )

    # Add in the cruising time if cruising occured
    if cruising_distance > 0.0
      time += cruising_distance / CRUISING_SPEED
    end

    minutes = (60 * time).to_int

    return minutes

  end


  #* Returns the time of a layover in the given by code city .
  #* The time depends on outbound flights from the city.
  def calculate_layover_time(city_code)

    reduction_minutes = [ (@nodes[city_code].neighbors.size - 1) * 10, 0].max
    minutes = BASE_LAYOVER_TIME_MINS - reduction_minutes 
    minutes = [minutes, 0].max

    return minutes

  end

end
