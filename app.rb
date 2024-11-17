require 'rack'
require 'json'
require_relative 'database/migrations/migrate'
require_relative 'src/controllers/user_controller'
require_relative 'src/controllers/order_controller'
require_relative 'src/controllers/api_controller'
require_relative 'src/file_processor'

# Rodar as migrações
Migrator.migrate

# Processar e salvar os dados do arquivo no banco
# file_paths = ['challenge/data_1.txt', 'challenge/data_2.txt']
# FileProcessor.save_data_to_db(file_paths)

class Application
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    case req.path
    when '/'
      ApiController.handle_request(req, res)
    when '/users'
      UserController.handle_request(req, res)
    when '/orders'
      OrderController.handle_request(req, res)
    else
      res.status = 404
      res.write({ error: 'Not Found' }.to_json)
    end

    res.finish
  end
end


