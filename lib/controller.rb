require File.join(File.dirname(__FILE__), 'node')
require File.join(File.dirname(__FILE__), 'graph')
require File.join(File.dirname(__FILE__), 'edge')
require File.join(File.dirname(__FILE__), 'string')

# primary application controller, handles all user input and command-line output

class Controller
  # main control loop
  def begin
    while true
      @nodes = get_nodes_from_user
      unless @nodes == 0
        @edge_probability = get_edge_probability_from_user
        @max_edge_weight = get_max_edge_weight_from_user

        puts "Processing..."
        construct_graph
        test_graph
        puts "Complete\n\n"
      else
        puts "Goodbye!\n\n"
        exit
      end
    end
  end

  private
    def construct_graph
      @graph = Graph.new(@nodes, @edge_probability, @max_edge_weight)
    end

    def test_graph
      raise "Cannot test graph until it has been constructed" if @graph.nil?

      puts " - The graph is: " + (@graph.is_complete? ? 'complete' : 'incomplete')

      print " - The graph is: "
      if @graph.is_fully_connected?
        print 'fully connected'
      else
        print 'not fully connected'
      end
      print " (using BFS)\n"

      if @graph.is_fully_connected?
        begin
          puts " - The MST weight is: #{@graph.get_mst_weight} (using prim's algorithm)"
        rescue Exception => detail
          puts " - Failed to calculate MST: #{detail}"
        end
      else
        puts " - Cannot calculate MST weight because graph is not fully connected"
      end
    end

    def get_nodes_from_user
      puts "How many nodes are we working with here (enter 0 to exit)? "
      nodes = gets.chomp

      if nodes.is_int?
        return nodes.to_i
      else
        puts " * Well that's not an integer!  Try again."
        get_nodes_from_user
      end
    end

    def get_edge_probability_from_user
      puts "What is the probability that each edge is created (0-1)? "
      edge_probability = gets.chomp

      if edge_probability.is_float?
        return edge_probability.to_f
      else
        puts " * Well that's not an float between zero and one!  Try again."
        get_edge_probability_from_user
      end
    end

    def get_max_edge_weight_from_user
      puts "What is the maximum weight of each edge (>1)? "
      max_edge_weight = gets.chomp

      if max_edge_weight.is_int? and max_edge_weight.to_i > 1
        return max_edge_weight.to_i
      else
        puts " * Well that's not an integer greater than 1!  Try again."
        get_max_edge_weight_from_user
      end
    end
end
