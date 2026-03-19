# frozen_string_literal: true

require "test_helper"
require "algebra_suite/boolean_simplifier"

class TestBooleanStructure < Minitest::Test
  include AlgebraSuite

  def test_variable_to_s
    assert_equal "A", Variable.new("a").to_s
    assert_equal "VAR", Variable.new("var").to_s
  end

  def test_variable_equality
    assert_equal Variable.new("a"), Variable.new("A")
    refute_equal Variable.new("A"), Variable.new("B")
    refute_equal Variable.new("A"), "A"
  end

  def test_not_structure
    var = Variable.new("A")
    not_node = Not.new(var)
    assert_equal "(NOT A)", not_node.to_s
    assert_equal var, not_node.operand
  end

  def test_not_equality
    a = Variable.new("A")
    assert_equal Not.new(a), Not.new(a)
    refute_equal Not.new(a), Not.new(Variable.new("B"))
  end

  def test_and_structure
    a = Variable.new("A")
    b = Variable.new("B")
    node = And.new(a, b)
    assert_equal "(A AND B)", node.to_s
    assert_equal a, node.left
    assert_equal b, node.right
  end

  def test_or_structure
    a = Variable.new("A")
    b = Variable.new("B")
    node = Or.new(a, b)
    assert_equal "(A OR B)", node.to_s
    assert_equal a, node.left
    assert_equal b, node.right
  end

  def test_invalid_operand
    assert_raises(ArgumentError) do
      Not.new("string instead of node")
    end

    assert_raises(ArgumentError) do
      And.new(Variable.new("A"), "B")
    end

    assert_raises(ArgumentError) do
      Or.new("A", Variable.new("B"))
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

  def test_parse_constants
    parser = Parser.new
    ast_true = parser.parse("TRUE")
    assert_instance_of Variable, ast_true
    assert_equal "TRUE", ast_true.to_s

    ast_false = parser.parse("FALSE")
    assert_instance_of Variable, ast_false
    assert_equal "FALSE", ast_false.to_s
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

  def test_parse_double_not
    parser = Parser.new
    ast = parser.parse("NOT NOT A")
    assert_instance_of Not, ast
    assert_instance_of Not, ast.operand
    assert_equal "(NOT (NOT A))", ast.to_s
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
    assert_equal "(A AND ((NOT B) OR C))", ast.to_s
  end

  def test_parse_no_spaces
    parser = Parser.new
    ast = parser.parse("(A AND B)OR(C AND D)")
    assert_equal "((A AND B) OR (C AND D))", ast.to_s
  end

  def test_parse_deeply_nested
    parser = Parser.new
    ast = parser.parse("((A OR B) AND (C OR D))")
    assert_instance_of And, ast
    assert_equal "((A OR B) AND (C OR D))", ast.to_s
  end

  def test_syntax_error_unexpected_token
    parser = Parser.new
    assert_raises(SyntaxError) do
      parser.parse("A AND")
    end

    assert_raises(SyntaxError) do
      parser.parse("AND B")
    end

    assert_raises(SyntaxError) do
      parser.parse("A OR OR B")
    end
  end

  def test_syntax_error_unclosed_parenthesis
    parser = Parser.new
    assert_raises(SyntaxError) do
      parser.parse("(A AND B")
    end
  end

  def test_parse_empty_string
    parser = Parser.new
    assert_nil parser.parse("")
  end
end

# покрытие законов
class TestBooleanSimplification < Minitest::Test
  include AlgebraSuite

  def test_simplify_identity
    assert_equal "A", BooleanSimplifier.simplify_expression("A")
  end

  #  Законы с константами and
  def test_simplify_and_with_true
    assert_equal "A", BooleanSimplifier.simplify_expression("A AND TRUE")
    assert_equal "A", BooleanSimplifier.simplify_expression("TRUE AND A")
  end

  def test_simplify_and_with_false
    assert_equal "FALSE", BooleanSimplifier.simplify_expression("A AND FALSE")
    assert_equal "FALSE", BooleanSimplifier.simplify_expression("FALSE AND A")
  end

  #  Законы с константами or
  def test_simplify_or_with_true
    assert_equal "TRUE", BooleanSimplifier.simplify_expression("A OR TRUE")
    assert_equal "TRUE", BooleanSimplifier.simplify_expression("TRUE OR A")
  end

  def test_simplify_or_with_false
    assert_equal "A", BooleanSimplifier.simplify_expression("A OR FALSE")
    assert_equal "A", BooleanSimplifier.simplify_expression("FALSE OR A")
  end

  #  Идемпотентность
  def test_simplify_idempotent_and
    assert_equal "A", BooleanSimplifier.simplify_expression("A AND A")
  end

  def test_simplify_idempotent_or
    assert_equal "A", BooleanSimplifier.simplify_expression("A OR A")
  end

  #  Отрицание и двойное отрицание
  def test_simplify_double_not
    assert_equal "A", BooleanSimplifier.simplify_expression("NOT NOT A")
    assert_equal "A", BooleanSimplifier.simplify_expression("NOT NOT NOT NOT A")
  end

  def test_simplify_not_constants
    assert_equal "FALSE", BooleanSimplifier.simplify_expression("NOT TRUE")
    assert_equal "TRUE", BooleanSimplifier.simplify_expression("NOT FALSE")
  end

  #  Противоречие и Тавтология
  def test_simplify_contradiction
    assert_equal "FALSE", BooleanSimplifier.simplify_expression("A AND (NOT A)")
    assert_equal "FALSE", BooleanSimplifier.simplify_expression("(NOT A) AND A")
  end

  def test_simplify_tautology
    assert_equal "TRUE", BooleanSimplifier.simplify_expression("A OR (NOT A)")
    assert_equal "TRUE", BooleanSimplifier.simplify_expression("(NOT A) OR A")
  end

  #  Закон поглощения
  def test_simplify_absorption_or
    assert_equal "A", BooleanSimplifier.simplify_expression("A OR (A AND B)")
    assert_equal "A", BooleanSimplifier.simplify_expression("A OR (B AND A)")
  end

  def test_simplify_absorption_and
    # A AND (A OR B) = A
    assert_equal "A", BooleanSimplifier.simplify_expression("A AND (A OR B)")
    assert_equal "A", BooleanSimplifier.simplify_expression("A AND (B OR A)")
  end

  #  Правило склеивания
  def test_simplify_adjacency
    # (A AND B) OR (A AND NOT B) = A
    assert_equal "A", BooleanSimplifier.simplify_expression("(A AND B) OR (A AND NOT B)")
    assert_equal "A", BooleanSimplifier.simplify_expression("(A AND NOT B) OR (A AND B)")

    # Варианты с перестановкой операндов внутри AND
    assert_equal "A", BooleanSimplifier.simplify_expression("(B AND A) OR (NOT B AND A)")
  end

  #  Сложные составные выражения
  def test_simplify_complex_cascade
    # Несколько применений правил подряд
    assert_equal "A", BooleanSimplifier.simplify_expression("NOT NOT A AND TRUE")
  end

  def test_simplify_deeply_nested_simplification
    expr = "NOT (NOT (A AND TRUE))"

    assert_equal "A", BooleanSimplifier.simplify_expression(expr)
  end

  def test_simplify_complex_stable
    # Выражение, которое нельзя упростить дальше
    result = BooleanSimplifier.simplify_expression("(A AND B) OR (C AND D)")
    assert_equal "((A AND B) OR (C AND D))", result
  end
end
