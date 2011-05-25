class Node
  attr_accessor :color
  attr_accessor :d
  attr_accessor :prev
  attr_reader :index
  def initialize(index)
    @index = index
  end
end
