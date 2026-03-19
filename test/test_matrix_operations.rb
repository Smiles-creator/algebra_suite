# frozen_string_literal: true

require "test_helper"
require "algebra_suite/matrix_operations"

class TestMatrixOperations < Minitest::Test
  include AlgebraSuite

  def test_vector_size
    vector = Vector.new([1, 2, 3])
    assert_equal 3, vector.size
  end

  def test_vector_addition
    v1 = Vector.new([1, 2, 3])
    v2 = Vector.new([4, 5, 6])

    result = v1 + v2

    assert_equal [5.0, 7.0, 9.0], result.to_a
  end

  def test_vector_scalar_multiplication
    vector = Vector.new([1, 2, 3])

    result = vector * 2

    assert_equal [2.0, 4.0, 6.0], result.to_a
  end

  def test_vector_dot_product
    v1 = Vector.new([1, 2, 3])
    v2 = Vector.new([4, 5, 6])

    assert_equal 32.0, v1.dot(v2)
  end

  def test_matrix_row_and_column_count
    matrix = Matrix.new([[1, 2], [3, 4], [5, 6]])

    assert_equal 3, matrix.row_count
    assert_equal 2, matrix.column_count
  end

  def test_matrix_addition
    m1 = Matrix.new([[1, 2], [3, 4]])
    m2 = Matrix.new([[5, 6], [7, 8]])

    result = m1 + m2

    assert_equal [[6.0, 8.0], [10.0, 12.0]], result.to_a
  end

  def test_matrix_subtraction
    m1 = Matrix.new([[5, 6], [7, 8]])
    m2 = Matrix.new([[1, 2], [3, 4]])

    result = m1 - m2

    assert_equal [[4.0, 4.0], [4.0, 4.0]], result.to_a
  end

  def test_matrix_scalar_multiplication
    matrix = Matrix.new([[1, 2], [3, 4]])

    result = matrix * 2

    assert_equal [[2.0, 4.0], [6.0, 8.0]], result.to_a
  end

  def test_matrix_vector_multiplication
    matrix = Matrix.new([[1, 2], [3, 4]])
    vector = Vector.new([1, 2])

    result = matrix * vector

    assert_equal [5.0, 11.0], result.to_a
  end

  def test_matrix_matrix_multiplication
    m1 = Matrix.new([[1, 2], [3, 4]])
    m2 = Matrix.new([[5, 6], [7, 8]])

    result = m1 * m2

    assert_equal [[19.0, 22.0], [43.0, 50.0]], result.to_a
  end

  def test_matrix_determinant
    matrix = Matrix.new([[1, 2], [3, 4]])

    assert_equal(-2.0, matrix.determinant)
  end

  def test_matrix_rank
    matrix = Matrix.new([[1, 2], [2, 4]])

    assert_equal 1, matrix.rank
  end

  def test_matrix_inverse
    matrix = Matrix.new([[1, 2], [3, 4]])

    result = matrix.inverse.to_a

    assert_in_delta(-2.0, result[0][0], 0.0001)
    assert_in_delta(1.0, result[0][1], 0.0001)
    assert_in_delta(1.5, result[1][0], 0.0001)
    assert_in_delta(-0.5, result[1][1], 0.0001)
  end

  def test_solve_linear_system
    matrix = Matrix.new([[1, 2], [3, 4]])
    vector = Vector.new([5, 11])

    result = matrix.solve(vector)

    assert_in_delta 1.0, result.to_a[0], 0.0001
    assert_in_delta 2.0, result.to_a[1], 0.0001
  end

  def test_gaussian_elimination_returns_matrix
    matrix = Matrix.new([[1, 2], [3, 4]])

    result = matrix.gaussian_elimination

    assert_instance_of Matrix, result
  end

  def test_invalid_matrix_raises_error
    assert_raises(ArgumentError) do
      Matrix.new([[1, 2], [3]])
    end
  end

  def test_invalid_vector_raises_error
    assert_raises(ArgumentError) do
      Vector.new([])
    end
  end
end
