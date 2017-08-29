require 'minitest/autorun'
require './app/helloworld.rb'

class TestHelloworld < Minitest::Test
  def setup
    @a = App::App.new
  end
  
  def test_that_hello_prints_world
    assert_equal 'world', @a.hello
  end
end
