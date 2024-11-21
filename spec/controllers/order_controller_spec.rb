require './app'
require 'rack/test'
require_relative '../spec_helper'
require_relative '../../src/controllers/order_controller'
require_relative '../../database/migrations/migrate'
require_relative '../../src/services/file_service'

RSpec.describe OrderController do
  include Rack::Test::Methods
  def app
    Application.new
  end

  describe 'GET /' do
    it 'retorna status 200 e dados em formato JSON' do
      get '/orders'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      json_response = JSON.parse(last_response.body)
      expect(json_response).to have_key('orders')
      expect(json_response).to have_key('page')
      expect(json_response).to have_key('size')
      expect(json_response).to have_key('total_orders')
      expect(json_response).to have_key('total_pages')
    end
  end
end