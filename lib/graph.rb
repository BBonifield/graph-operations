class Graph
  # constants used in BFS and Prim's
  INFINITY=999999999
  BLACK='black'
  GRAY='gray'
  WHITE='white'

  def initialize(nodes, edge_probability, max_edge_weight)
    @mst_weight = nil
    @is_complete = nil
    @is_fully_connected = nil

    @nodes = nodes
    @edge_probability = edge_probability
    @max_edge_weight = max_edge_weight

    # edge matrix tracks the existence of each edge
    initialize_edge_matrix
    # node array stores objects representing each node in the graph
    initialize_node_array

    # seed the graph based on the edge probability and max edge weight
    construct_directed_edges
    # remove edges that are not symmetric
    prune_unconnected_edges
  end

  def is_complete?
    # don't recalculate completeness
    if @is_complete.nil?
      @is_complete = true
      @edge_matrix.each_with_index{ |edge, source, destination|
        # loops are never allowed
        unless source == destination
          @is_complete = @is_complete && edge.exists?
        end
      }
    end
    @is_complete
  end

  def is_fully_connected?
    # don't recalculate connectedness if ran twice
    if @is_fully_connected.nil?
      if @nodes == 1
        @is_fully_connected = true
      else
        # implementation of BFS to check connectedness
        source_node = @node_array[0]
        queue = Queue.new
        queue.push(source_node)
        until queue.empty?
          u = queue.pop
          get_nodes_adjacent_to_node(u).each { |node_index|
            v = @node_array[node_index]
            if v.color == WHITE
              v.color = GRAY
              v.d = u.d + 1
              v.prev = u
              queue.push(v)
            end
          }
          u.color = BLACK
        end

        @is_fully_connected = true
        @node_array.each { |node|
          @is_fully_connected = @is_fully_connected && (node.color == BLACK)
        }
      end
    end
    @is_fully_connected
  end

  def get_mst_weight
    if @mst_weight.nil?
      raise "Can't calculate MST weight - unconnected" unless is_fully_connected?

      @mst_weight = prim(@node_array[0])
    end
    @mst_weight
  end

  private


    def prim(source_node)
      # initialize single source
      @node_array.each do |node|
        node.d = INFINITY
        node.prev = nil
        node.color = WHITE
      end  
      @node_array[source_node.index].d = 0

      q = Array.new
      q.push(source_node)
      source_node.d = 0
      until q.empty?
        # extract min
        u = nil
        q.each do |min_node|
          if (not u) or (min_node.d and min_node.d < u.d)
            u = min_node
          end
        end
        q = q - [u]

        # error check if u is invalid
        raise "Minimum node has improper distance" if u.d == INFINITY

        get_nodes_adjacent_to_node(u).each do |v|
          v = @node_array[v]
          weight_for_edge = @edge_matrix[u.index, v.index].weight
          if v.color == WHITE
            v.color = GRAY
            v.d = weight_for_edge
            v.prev = u
            q.push(v)
          elsif v.color == GRAY
            if v.d > weight_for_edge
              v.d = weight_for_edge
              v.prev = u
            end
          end
        end
        u.color = BLACK
      end

      # sum up the selected edge weights
      weight = 0
      @node_array.each do |node|
        unless node.prev.nil?
          weight += @edge_matrix[node.prev.index, node.index].weight
        end
      end
      weight
    end

    def initialize_edge_matrix
      @edge_matrix = Matrix.build(@nodes) { |source, destination|
        Edge.new(source, destination)
      }
    end

    def initialize_node_array
      @node_array = Array.new(@nodes) { |node_index|
        node = Node.new(node_index)
        node.color = WHITE
        node.d = INFINITY
        node.prev = nil
        node
      }
    end

    def construct_directed_edges
      @edge_matrix.each_with_index{ |edge, source, destination|
        # loops are never allowed
        unless source == destination
          if should_create_edge?
            edge.add_with_weight(get_random_weight)
          end
        end
      }
    end

    def prune_unconnected_edges
      @edge_matrix.each_with_index{ |edge, source, destination|
        # loops are never allowed
        unless source == destination
          if edge.exists?
            inverse_edge = @edge_matrix[destination, source]
            unless inverse_edge.exists?
              edge.remove
            end
          end
        end
      }
    end

    def should_create_edge?
      rand <= @edge_probability
    end

    def get_random_weight
      (rand * (@max_edge_weight - 1) + 1).round
    end

    def get_nodes_adjacent_to_node(source_node)
      adjacent_nodes = []
      destination_node_index = 0
      # look for directed edges between the source node and each possible
      # destination node
      @edge_matrix.row(source_node.index) { |edge|
        if edge.exists?
          adjacent_nodes.push(destination_node_index)
        end
        destination_node_index += 1
      }
      adjacent_nodes
    end
end
