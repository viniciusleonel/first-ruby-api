require 'rack'
require 'json'
require_relative 'database/migrations/migrate'
require_relative 'src/controllers/user_controller'
require_relative 'src/controllers/order_controller'
require_relative 'src/controllers/api_controller'
require_relative 'src/controllers/file_controller'

Migrator.rollback
Migrator.migrate

class Application
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    id = req.path.split('/').last.to_i if req.path.split('/').last =~ /\d/

    case req.path
    when '/'
      ApiController.handle_request(req, res)
    when '/orders'
      OrderController.handle_request(req, res)
    when "/orders/#{id}"
      OrderController.handle_request_order_by_id(req, res, id)
    when "/upload"
      FileController.handle_request(req, res)
    else
      res.status = 404
      res.write({ error: 'Endpoint Not Found' }.to_json)
    end

    res.finish
  end
end


