# routes/boolean_routes.rb
require 'json'
require_relative '../lib/algebra_suite/boolean_simplifier'


post '/api/simplify' do
  content_type :json
  begin
    data = JSON.parse(request.body.read)
    expression = data['expression']
    
    unless expression && expression.is_a?(String)
      halt 400, { error: 'Требуется параметр "expression" (строка)' }.to_json
    end
    
    result = AlgebraSuite::BooleanSimplifier.simplify_expression(expression)
    
    {
      status: 'success',
      operation: 'simplify',
      input: expression,
      result: result
    }.to_json
    
  rescue AlgebraSuite::SyntaxError => e
    halt 400, {
      status: 'error',
      error: 'SyntaxError',
      message: e.message
    }.to_json
  rescue => e
    halt 500, {
      status: 'error',
      error: 'InternalServerError',
      message: e.message
    }.to_json
  end
end

post '/api/validate' do
  content_type :json
  begin
    data = JSON.parse(request.body.read)
    expression = data['expression']
    
    unless expression && expression.is_a?(String)
      halt 400, { error: 'Требуется параметр "expression"' }.to_json
    end
    
    parser = AlgebraSuite::Parser.new
    ast = parser.parse(expression)
    
    {
      status: 'success',
      operation: 'validate',
      input: expression,
      valid: true,
      message: 'Выражение корректно'
    }.to_json
    
  rescue AlgebraSuite::SyntaxError => e
    halt 400, {
      status: 'error',
      operation: 'validate',
      input: expression,
      valid: false,
      error: 'SyntaxError',
      message: e.message
    }.to_json
  end
end

get '/api/boolean/laws' do
  content_type :json
  {
    status: 'success',
    operation: 'laws',
    laws: {
      identity: 'A AND TRUE = A',
      annihilation: 'A AND FALSE = FALSE',
      idempotent: 'A AND A = A',
      double_negation: 'NOT (NOT A) = A',
      contradiction: 'A AND (NOT A) = FALSE',
      tautology: 'A OR (NOT A) = TRUE',
      absorption: 'A AND (A OR B) = A',
      adjacency: '(A AND B) OR (A AND NOT B) = A'
    }
  }.to_json
end