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

class TestBooleanParser < Minitest::Test
  include AlgebraSuite

  def test_parse_simple_var
    parser = Parser.new
    ast = parser.parse("A")
    assert_instance_of Variable, ast
    assert_equal "A", ast.to_s
  end

  def test_parse_and
    parser = Parser.new
    ast = parser.parse("A AND B")
    assert_instance_of And, ast
    assert_equal "(A AND B)", ast.to_s
  end

  def test_parse_or
    parser = Parser.new
    ast = parser.parse("A OR B")
    assert_instance_of Or, ast
    assert_equal "(A OR B)", ast.to_s
  end

  def test_parse_not
    parser = Parser.new
    ast = parser.parse("NOT A")
    assert_instance_of Not, ast
    assert_equal "(NOT A)", ast.to_s
  end

  def test_parse_precedence_and_or
    parser = Parser.new
    ast = parser.parse("A OR B AND C")
    assert_instance_of Or, ast
    assert_instance_of And, ast.right
    assert_equal "(A OR (B AND C))", ast.to_s
  end

  def test_parse_precedence_not_and
    parser = Parser.new
    ast = parser.parse("NOT A AND B")
    assert_instance_of And, ast
    assert_instance_of Not, ast.left
    assert_equal "((NOT A) AND B)", ast.to_s
  end

  def test_parse_parentheses
    parser = Parser.new
    ast = parser.parse("(A OR B) AND C")
    assert_instance_of And, ast
    assert_instance_of Or, ast.left
    assert_equal "((A OR B) AND C)", ast.to_s
  end
  
  def test_parse_complex
    parser = Parser.new
    ast = parser.parse("A AND (NOT B OR C)")
    # Добавлена проверка результата
    assert_equal "(A AND ((NOT B) OR C))", ast.to_s
  end

  def test_syntax_error
    parser = Parser.new
    assert_raises(SyntaxError) do
      parser.parse("A AND")
    end
  end
end

class TestBooleanSimplification < Minitest::Test
  include AlgebraSuite

  def test_simplify_double_not
    assert_equal "A", BooleanSimplifier.simplify_expression("NOT NOT A")
  end

  def test_simplify_and_true
    assert_equal "A", BooleanSimplifier.simplify_expression("A AND TRUE")
  end

  def test_simplify_and_false
    assert_equal "FALSE", BooleanSimplifier.simplify_expression("A AND FALSE")
  end

  def test_simplify_or_true
    assert_equal "TRUE", BooleanSimplifier.simplify_expression("A OR TRUE")
  end

  def test_simplify_absorption
    assert_equal "A", BooleanSimplifier.simplify_expression("A OR (A AND B)")
  end
  
  def test_simplify_contradiction
    assert_equal "FALSE", BooleanSimplifier.simplify_expression("A AND (NOT A)")
  end
end