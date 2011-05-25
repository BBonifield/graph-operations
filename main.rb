# built-in classes
require 'matrix'
require 'thread'

# custom classes
require File.join(File.dirname(__FILE__), 'lib/controller')

# it's go time
controller = Controller.new
controller.begin
