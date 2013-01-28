require 'graph.rb'

=begin

  This code runs a console for presenting CS Air data to user

  @author Timur Reziapov <reziapo1@illinois.edu>
  @date Sunday, September 31, 2012 15:00 PM

=end

puts "Welcome to CS Air Console!"

# Initialize the Graph for CS Air
graph = Graph.new()
graph.parse_json_file("CSAirData.json")

help_text = "Available Commands:\n" + 
            "'help'\n" + 
            "'list cities', 'city info'\n" +
            "'longest flight', 'shortest flight', 'average flight'\n" +
            "'biggest city', 'smallest city', 'average population'\n" +
            "'continents', 'hub cities'\n" +
            "'map all', 'map'\n" +
            "'remove route', 'remove city'\n" +
            "'add route', 'add city', 'edit city'\n" +
            "'route info', 'get shortest route'\n" + 
            "'expand', save'\n"

puts help_text

# Opens the generated in Firefox
def display_map
  system("open -a /Applications/Firefox.app/Contents/MacOS/firefox-bin map.gif")
end


def display_route_stats(codes, graph)

  distance, cost, minutes =  graph.get_route_info(*codes)
  hours, minutes = minutes.divmod(60)
  days, hours = hours.divmod(24)
  puts "Total distance: #{distance} kilometers"
  puts "Total cost: $#{cost}"
  puts "Total time: #{days} days, #{hours} hours, #{minutes} minutes"

end


# Keep asking the user for data to make a new city or update existing one.
# Returns a formatted hash.
def build_city_data_hash( nil_if_no_entry = false )

  new_city_hash = Hash.new()

  while true
    puts "Enter code"
    input = gets.chop
    if input.size != 0
      new_city_hash["code"] = input
      break
    elsif input.size == 0 && nil_if_no_entry
      break 
    end
  end

  while true
    puts "Enter name"
    input = gets.chop
    if input.size != 0
      new_city_hash["name"] = input
      break
    elsif input.size == 0 && nil_if_no_entry
      break 
    end
  end

  while true
    puts "Enter country"
    input = gets.chop
    if input.size != 0
      new_city_hash["country"] = input
      break
    elsif input.size == 0 && nil_if_no_entry
      break 
    end
  end

  while true
    puts "Enter continent"
    input = gets.chop
    if input.size != 0
      new_city_hash["continent"] = input
      break
    elsif input.size == 0 && nil_if_no_entry
      break 
    end
  end

  while true
    puts "Enter timezone"
    input = gets.chop
    if input.size != 0
      new_city_hash["timezone"] = Integer(input)
      break
    elsif input.size == 0 && nil_if_no_entry
      break 
    end
  end

  coords = Hash.new()
  while true
    puts "Enter coordinates, ie N 10 W 10"
    input = gets.chop
    latitude = input.upcase.scan( /N|S/ )[0]
    longitude = input.upcase.scan( /W|E/ )[0]
    numbers = input.scan( /\d+/ )

    break if nil_if_no_entry && (latitude.nil? || longitude.nil? || numbers.size < 2)

    next if numbers[0].nil? || latitude.nil?
    coords[latitude] = Integer( numbers[0] )

    next if numbers[1].nil? || longitude.nil?
    coords[longitude] = Integer( numbers[1] )

    break
  end

  if !coords.empty?
    new_city_hash["coordinates"] = coords
  end

  while true
    puts "Enter population"
    input = gets.chop
    if input.size != 0
      new_city_hash["population"] = Integer(input)
      break
    elsif input.size == 0 && nil_if_no_entry
      break 
    end
  end

   while true
    puts "Enter region"
    input = gets.chop
    if input.size != 0
      new_city_hash["region"] = Integer(input)
      break
    elsif input.size == 0 && nil_if_no_entry
      break 
    end
  end

  return new_city_hash

end


# Fuction to avoid duplication
def get_origin_and_destination()
    puts "Choose origin city code"
    origin = gets.chop
    puts "Choose destination city code"
    destination = gets.chop
    return origin, destination
end



# Console Loop
while (true)

  puts "Enter a command"
  command = gets
  
  case command.chop
    
  when "help"
    puts help_text
    
  when "list cities"
    puts graph.get_all_cities()
    
  when "details"
    puts "Choose a city code"
    code = gets.chop
    puts graph.get_specific_info(code)
    
  when "longest flight"
    puts graph.get_longest_flight()
    
  when "shortest flight"
    puts graph.get_shortest_flight()
    
  when "average flight"
    puts graph.get_average_distance()
    
  when "biggest city"
    puts graph.get_biggest_city()
    
  when "smallest city"
    puts graph.get_smallest_city()
    
  when "average population"
    puts graph.get_average_population()
    
  when "continents"
    graph.get_continents_with_cities().each do |cont, cities|
      puts cont
      cities.each {|city| print city + " "}
      puts
    end
    
  when "hub cities"
    puts graph.get_hub_cities()
    
  when "map all"
    graph.map(graph.format_all_edges())
    display_map
    
  when "map"
    origin, destination = get_origin_and_destination()
    
    path = graph.get_dijkstra_path(origin,destination)   
    if path.nil?()
      puts "Code doesn't exist"
      next
    end
    
    graph.map(path)
    display_map
        

  # Assignment 2.1 Additions

  when "remove city"
    puts "Choose a city to remove"
    remove_code = gets.chop

    if graph.remove_node(remove_code)
      puts "Successfuly removed #{remove_code} from the network!"
    else
      puts "Failed ro remove #{remove_code}. City not in the network!"
    end
  

  when "remove route"
    origin, destination = get_origin_and_destination()

    if graph.remove_edge(origin, destination)
      puts "Successful removed #{origin}-#{destination} route!"
    else
      puts "Couldn't delete the route. Either codes don't exists or route is non-direct!"
    end
    

  when "add city"
    new_city_hash = build_city_data_hash

    begin
      graph.add_node(new_city_hash)
    rescue
      puts "Couldn't add the new city, either invalid format or city already exists!"
    end


  when "add route"
    origin, destination = get_origin_and_destination()
    puts "Choose distance for the route"
    distance = Integer( gets.chop )

    begin
      graph.add_edge(origin, destination, distance)
    rescue
      puts "Couldn't add the route, either invalid codes or distance!"
    end


  when "edit city"
    puts "Choose existing city code"
    original = gets.chop

    updated_hash = build_city_data_hash(true)

    begin 
      graph.edit_node(original, updated_hash)
    rescue
      puts "Couldn't edit #{original} information."
    end


  when "save"
    json_string = graph.to_json
    ext = ".json"

    puts "Choose file name"
    filename = gets.chop + ext

    if File.exists?(filename)
      puts "File already exists, continue?"
      if !gets.chop.upcase.include?("Y")
        next
      end
    end

    file = File.new(filename, "w")
    file.write(json_string)
    file.close
    puts "Data saved as #{filename}!"


  when "route info"
    puts "Enter at least 2 routes codes (must be direct flights)"
    codes = gets.chop.scan(/[A-Z]{3}/)

    begin 
      display_route_stats(codes, graph)
    rescue
      puts "Error occured while checking the route. Check your route is valid!"
    end


  when "get shortest route"
    origin, destination = get_origin_and_destination()

    path = graph.get_dijkstra_path(origin, destination)
    if path.nil?
      puts "Error with given codes!"
      next
    end
    puts path
    display_route_stats(path.scan(/[A-Z]{3}/), graph)


  when "expand"
    ext = ".json"
    puts "Enter name of the .json file to add"
    filename = gets.chop + ext

    if !File.exists?(filename)
      puts "File doesn't exist!"
      next
    end
    if !graph.parse_json_file(filename)
      puts "Data expansion failed! Check file."
      next
    end
    puts "Expansion successfull!"


  when "exit"
    break

  when "quit"    
    break

  else
    puts "No such command"
  end
  
  puts "" 
  next
  
end