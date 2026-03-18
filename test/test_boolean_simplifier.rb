require "test_helper"
require "algebra_suite/boolean_simplifier"

class TestBooleanStructure < Minitest::Test
  include AlgebraSuite

  def test_variable_to_s
    assert_equal "A", Variable.new("a").to_s
    assert_equal "VAR", Variable.new("var").to_s
  end

  def test_not_structure
    var = Variable.new("A")
    not_node = Not.new(var)
    assert_equal "(NOT A)", not_node.to_s
  end

  def test_and_structure
    a = Variable.new("A")
    b = Variable.new("B")
    node = And.new(a, b)
    assert_equal "(A AND B)", node.to_s
  end

  def test_or_structure
    a = Variable.new("A")
    b = Variable.new("B")
    node = Or.new(a, b)
    assert_equal "(A OR B)", node.to_s
  end
  
  def test_invalid_operand
    assert_raises(ArgumentError) do
      Not.new("string instead of node")
    end
  end
end