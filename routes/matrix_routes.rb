# routes/matrix_routes.rb
require 'json'
require_relative '../lib/algebra_suite/matrix_operations'

helpers do
  def json_body
    JSON.parse(request.body.read)
  end

  def matrix_from(data, key = 'matrix')
    AlgebraSuite::Matrix.new(data[key])
  end

  def vector_from(data, key = 'vector')
    AlgebraSuite::Vector.new(data[key])
  end

  def matrix_response(operation, result)
    {
      status: 'success',
      operation: operation,
      result: result.respond_to?(:to_a) ? result.to_a : result
    }.to_json
  end
end

post '/api/matrix/add' do
  content_type :json
  data = json_body
  result = matrix_from(data, 'matrix_a') + matrix_from(data, 'matrix_b')
  matrix_response('add', result)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end

post '/api/matrix/subtract' do
  content_type :json
  data = json_body
  result = matrix_from(data, 'matrix_a') - matrix_from(data, 'matrix_b')
  matrix_response('subtract', result)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end

post '/api/matrix/multiply' do
  content_type :json
  data = json_body
  left = matrix_from(data, 'matrix')
  right = if data.key?('scalar')
            data['scalar']
          elsif data.key?('vector')
            vector_from(data)
          elsif data.key?('matrix_b')
            matrix_from(data, 'matrix_b')
          end

  halt 400, { status: 'error', message: 'Передайте scalar, vector или matrix_b' }.to_json unless right

  matrix_response('multiply', left * right)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end

post '/api/matrix/determinant' do
  content_type :json
  result = matrix_from(json_body).determinant
  matrix_response('determinant', result)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end

post '/api/matrix/rank' do
  content_type :json
  result = matrix_from(json_body).rank
  matrix_response('rank', result)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end

post '/api/matrix/inverse' do
  content_type :json
  result = matrix_from(json_body).inverse
  matrix_response('inverse', result)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end

post '/api/matrix/gaussian' do
  content_type :json
  result = matrix_from(json_body).gaussian_elimination
  matrix_response('gaussian', result)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end

post '/api/matrix/solve' do
  content_type :json
  data = json_body
  result = matrix_from(data).solve(vector_from(data))
  matrix_response('solve', result)
rescue JSON::ParserError
  halt 400, { status: 'error', message: 'Некорректный JSON' }.to_json
rescue ArgumentError => e
  halt 400, { status: 'error', message: e.message }.to_json
end
