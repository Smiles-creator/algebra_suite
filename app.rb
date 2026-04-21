# app.rb
require 'sinatra'
require 'json'
require_relative 'lib/algebra_suite/boolean_simplifier'

#ПОДКЛЮЧАЕМ МАРШРУТЫ
require_relative 'routes/boolean_routes'
# require_relative 'routes/matrix_routes'

# Настройки
set :bind, '0.0.0.0'
set :port, 4567
set :protection, :except => :json_csrf

before do
  content_type :json
end

# ГЛАВНАЯ СТРАНИЦА
get '/' do
  {
    status: 'ok',
    message: 'Algebra Bot API',
    version: '1.0.0',
    endpoints: {
      boolean: {
        simplify: 'POST /api/simplify',
        validate: 'POST /api/validate',
        laws: 'GET /api/boolean/laws'
      },
      matrix: {
        
      }
    }
  }.to_json
end

#ОБРАБОТКА ОШИБОК
error 404 do
  { status: 'error', error: 'NotFound', message: 'Endpoint not found' }.to_json
end

error 500 do
  { status: 'error', error: 'InternalServerError', message: 'Something went wrong' }.to_json
end