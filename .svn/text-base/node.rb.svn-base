
=begin

  This class will represent a node/vertex in the Graph class

  @author Timur Reziapov <reziapo1@illinois.edu>
  @date Sunday, September 31, 2012 15:00 PM

=end

class Node
   
  # Make all instance variables public
  attr_accessor :name, :code, :country, :continent, :timezone,
                :coordinates, :population, :region, :neighbors
            
  #* Node Constructor                              
  def initialize(city_hash)
    
    # If argument is nil, all instance variables will also be nil by default
    if city_hash.nil?
      return
    end
    
    # Initialize fields given by city_hash
    # By default, if key doesn't exist the value is nil
    @name = city_hash["name"]
    @code = city_hash["code"]
    @country = city_hash["country"]
    @continent = city_hash["continent"]
    @timezone = city_hash["timezone"]
    @coordinates = city_hash["coordinates"]
    @population = city_hash["population"]
    @region = city_hash["region"]
    
    # Initialize a map of neighbors, where:
    # Key - Code of the neighbor city,
    # Value - Distance to the neighbor city
    #        -1 if city isn't a neighbor, i.e. if key doesn't exist.
    @neighbors = Hash.new(-1)

  end


  #* A setter method. Sets class instance fields if argument hash specifies them.
  def update(new_hash)

    # If argument is nil, all instance variables will be unchanged.
    if new_hash.nil?
      return
    end

    # Update fields if they exists in the hash
    # NOTE: We won't modify neighbors through update
    if new_hash.key?("name") 
     @name = new_hash["name"] 
    end
    if new_hash.key?("code") 
      @code = new_hash["code"]
    end
    if new_hash.key?("country") 
      @country = new_hash["country"]
    end
    if new_hash.key?("continent") 
      @continent = new_hash["continent"]
    end
    if new_hash.key?("timezone") 
      @timezone = new_hash["timezone"] 
    end
    if new_hash.key?("coordinates") 
      @coordinates = new_hash["coordinates"] 
    end
    if new_hash.key?("population")
      @population = new_hash["population"] 
    end
    if new_hash.key?("region") 
      @region = new_hash["region"] 
    end

  end


  #* Returns true if other is a Node with the same contents,
  #* false otherwise.
  def eql?(other)

    return false if !other.instance_of? Node

    return @name.eql?(other.name) && 
            @code.eql?(other.code) &&
            @country.eql?(other.country) &&
            @continent.eql?(other.continent) &&
            @timezone.eql?(other.timezone) &&
            @coordinates.eql?(other.coordinates) &&
            @population.eql?(other.population) &&
            @region.eql?(other.region) &&
            @neighbors.eql?(other.neighbors)

  end
  
end