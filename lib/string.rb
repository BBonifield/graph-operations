class String
  def is_int?
    self =~ /^\d+$/
  end
  def is_float?
    self =~ /^0(\.\d+)?|1$/
  end
end
