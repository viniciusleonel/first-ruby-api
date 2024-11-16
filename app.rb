require 'rack'
require 'json'
require_relative 'database/migrations/migrate'
require_relative 'src/controller/user_controller'

Migrator.migrate

class Application
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    case req.path
    when '/users'
      if req.request_method == 'GET'
        res.status = 200
        res['Content-Type'] = 'application/json'
        res.write(UserController.index)
      elsif req.request_method == 'POST'
        res.status = 201
        res['Content-Type'] = 'application/json'
        res.write(UserController.create(req))
      end
    else
      res.status = 404
      res.write({ error: 'Not Found' }.to_json)
    end

    res.finish
  end
end

