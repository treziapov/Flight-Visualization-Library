require 'test/unit'
require 'node.rb'

=begin

  Unit tests for the Node class.

  @author Timur Reziapov <reziapo1@illinois.edu>
  @date Sunday, October 7th, 2012 17:00 PM

=end

class NodeTest < Test::Unit::TestCase

	#* Checks constructor
	def test_initialization()

		data_hash = {  
	    			"code" => "NYC" ,
	                "name" => "New York" ,
	                "country" => "US" ,
	                "continent" => "North America" ,
	                "timezone" => -5 ,
	                "coordinates" => { "N" => 41, "W" => 74 } ,
	                "population" => 22200000 ,
	                "region" => 3 }

	    test_node = Node.new(data_hash)

	    assert_equal(test_node.code, "NYC")
	    assert_equal(test_node.name, "New York")
	    assert_equal(test_node.country, "US")
	    assert_equal(test_node.continent, "North America")
	    assert_equal(test_node.population, 22200000)
	    assert_equal(test_node.coordinates, { "N" => 41, "W" => 74 } )
	    assert_equal(test_node.region, 3)

    end


    #* Checks update method
    def test_update()

    	# Start from a node with nil fields
    	test_node = Node.new(nil)

    	assert_nil( test_node.code )
    	assert_nil( test_node.region )

    	test_node.update( { "code" => "NYC" } )

    	assert_equal( test_node.code, "NYC" )
    	assert_nil( test_node.region )

    	test_node.update( { "name" => "New York"} )

    	assert_equal( test_node.name, "New York" )
    	assert_equal( test_node.code, "NYC" )

    	test_node.update( {  
    				"code" => "ABC" ,
	                "name" => "Alpha Beta" ,
	                "country" => "US" ,
	                "continent" => "North America" ,
	                "timezone" => -5 ,
	                "coordinates" => { "N" => 41, "W" => 74 } ,
	                "population" => 22200000 ,
	                "region" => 3 } )

    	# Check if new fields were added and existing fields udpated
	    assert_not_equal( test_node.code, "NYC" )
	    assert_not_equal( test_node.name, "New York" )
	    assert_equal( test_node.code, "ABC" )
   	    assert_equal( test_node.name, "Alpha Beta" )
   	    assert_equal( test_node.region, 3 )

   	    test_node.update( {} )

   	    # Check if call with empty hash didn't change anything
   	   	assert_equal( test_node.code, "ABC" )
   	    assert_equal( test_node.name, "Alpha Beta" )
   	    assert_equal( test_node.region, 3 )

    end


    # Checks the functionality of eql? method
    def test_eql?()

    	test_node = Node.new( {  
				    			"code" => "NYC" ,
				                "name" => "New York" ,
				                "country" => "US" ,
				                "continent" => "North America" ,
				                "timezone" => -5 ,
				                "coordinates" => { "N" => 41, "W" => 74 } ,
				                "population" => 22200000 ,
				                "region" => 3 } )

    	assert_equal( test_node.eql?(nil), false )
    	assert_equal( test_node.eql?( { "code" => "NYC" } ), false )

    	other_node = Node.new( {} )

    	assert_equal( test_node.eql?(other_node), false )
    	assert_equal( other_node.eql?(test_node), false )


    	other_node.update ( {  
			    			"code" => "NYC" ,
			                "name" => "New York" ,
			                "country" => "US" ,
			                "continent" => "North America" ,
			                "timezone" => -5 ,
			                "coordinates" => { "N" => 41, "W" => 74 } ,
			                "population" => 22200000 ,
			                "region" => 3 } )

    	assert_equal( test_node.eql?(other_node), true )
    	assert_equal( other_node.eql?(test_node), true )

    end

end