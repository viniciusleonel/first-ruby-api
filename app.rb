require 'rack'
require 'json'
require_relative 'database/migrations/migrate'
require_relative 'src/routes/router'

Migrator.migrate
Migrator.clean

class Application
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    Router.call(req, res)

    res.finish
  end
end


