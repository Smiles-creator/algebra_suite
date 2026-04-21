# app.rb
require 'sinatra'
require 'json'
require_relative 'lib/algebra_suite/boolean_simplifier'

# Настройки
set :bind, '0.0.0.0'
set :port, 4567
set :protection, :except => :json_csrf

before do
  content_type :json
end

# Главная страница
get '/' do
  {
    status: 'ok',
    message: 'Algebra Bot API',
    endpoints: {
      simplify: 'POST /api/simplify { expression: "A AND TRUE" }'
    }
  }.to_json
end

# Твой эндпоинт для упрощения
post '/api/simplify' do
  begin
    data = JSON.parse(request.body.read)
    expression = data['expression']
    
    unless expression
      halt 400, { error: 'Требуется параметр "expression"' }.to_json
    end
    
    result = AlgebraSuite::BooleanSimplifier.simplify_expression(expression)
    
    { status: 'success', result: result }.to_json
    
  rescue AlgebraSuite::SyntaxError => e
    halt 400, { error: 'Ошибка синтаксиса', message: e.message }.to_json
  rescue => e
    halt 500, { error: 'Внутренняя ошибка', message: e.message }.to_json
  end
end