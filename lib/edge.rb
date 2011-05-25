class Edge
  attr_reader :source
  attr_reader :destination
  attr_reader :weight
  def initialize(source, destination)
    @source = source
    @destination = destination
    @exists = false
    @weight = nil
  end

  def add_with_weight(weight)
    @exists = true
    @weight = weight
  end

  def remove
    @exists = false
    @weight = nil
  end

  def exists?
    @exists
  end
end
